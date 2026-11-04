package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.BookSyncResponse;
import com.gdailly.library.dto.CacheClearResponse;
import com.gdailly.library.dto.CacheScope;
import com.gdailly.library.dto.MetadataAdminResponse;
import com.gdailly.library.dto.MetadataSyncJobResponse;
import com.gdailly.library.dto.SyncMode;
import com.gdailly.library.dto.SyncOutcome;
import com.gdailly.library.dto.SyncState;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;

import jakarta.annotation.PreDestroy;

/**
 * Owner-only administration of book metadata: resynchronising one book or the whole library with the external
 * sources, and emptying the ISBN cache. The full resynchronisation runs in the background, one library at a time
 * per library, and only completes empty fields; a single book can also be overwritten (REPLACE).
 * No transaction spans the HTTP calls.
 */
@Service
public class MetadataSyncService {

    private static final Logger log = LoggerFactory.getLogger(MetadataSyncService.class);
    /** A resynchronisation reuses the answers fetched less than a day ago, so that it can be resumed cheaply. */
    static final Duration REUSE_RECENT_LOOKUPS = Duration.ofDays(1);

    private final LibraryBookRepository books;
    private final SeriesRegistry seriesRegistry;
    private final IsbnLookupRepository isbnCache;
    private final IsbnLookupService lookups;
    private final CoverService covers;
    private final BookService bookService;
    private final SyncHistoryService history;
    private final TransactionTemplate transaction;
    private final Clock clock;
    private final Duration pause;
    private final ExecutorService worker = Executors.newSingleThreadExecutor(Thread.ofVirtual().name("metadata-sync").factory());
    private final Map<Long, Job> jobs = new ConcurrentHashMap<>();

    MetadataSyncService(LibraryBookRepository books, SeriesRegistry seriesRegistry, IsbnLookupRepository isbnCache, IsbnLookupService lookups,
            CoverService covers, BookService bookService, SyncHistoryService history,
            PlatformTransactionManager transactionManager, Clock clock, LivreProperties properties) {
        this.books = books;
        this.seriesRegistry = seriesRegistry;
        this.isbnCache = isbnCache;
        this.lookups = lookups;
        this.covers = covers;
        this.bookService = bookService;
        this.history = history;
        this.transaction = new TransactionTemplate(transactionManager);
        this.clock = clock;
        this.pause = properties.isbn().syncPause();
    }

    @PreDestroy
    void stop() {
        worker.shutdownNow();
    }

    @Transactional(readOnly = true)
    public MetadataAdminResponse overview(CurrentUser user) {
        requireAdmin(user);
        return new MetadataAdminResponse(
                books.countByLibraryId(user.libraryId()),
                books.findBookIdsWithIsbn(user.libraryId()).size(),
                isbnCache.count(),
                isbnCache.countBySource(LookupSource.NOT_FOUND),
                job(user.libraryId()));
    }

    /** Progress of the library's full resynchronisation. */
    public MetadataSyncJobResponse status(CurrentUser user) {
        requireAdmin(user);
        return job(user.libraryId());
    }

    @Transactional
    public CacheClearResponse clearCache(CurrentUser user, CacheScope scope) {
        requireAdmin(user);
        int deleted = scope == CacheScope.ALL ? isbnCache.deleteAllEntries()
                : isbnCache.deleteAllBySource(LookupSource.NOT_FOUND);
        return new CacheClearResponse(deleted);
    }

    /**
     * Starts the resynchronisation of every book with an ISBN: FILL completes their empty fields only,
     * FETCH only refreshes the answers of the sources (to compare them before applying anything).
     */
    public synchronized MetadataSyncJobResponse startSyncAll(CurrentUser user, SyncMode mode) {
        requireAdmin(user);
        if (mode == SyncMode.REPLACE) {
            throw new BadRequestException("Tout remplacer n'est possible que livre par livre.");
        }
        Long libraryId = user.libraryId();
        Job current = jobs.get(libraryId);
        if (current != null && current.state == SyncState.RUNNING) {
            throw new ConflictException("Une resynchronisation est déjà en cours.");
        }
        List<Long> ids = transaction.execute(status -> books.findBookIdsWithIsbn(libraryId));
        Long runId = history.start(mode == SyncMode.FETCH ? SyncKind.METADATA_FETCH : SyncKind.METADATA_FILL, libraryId,
                user.email(), ids.size());
        Job job = new Job(ids.size(), Instant.now(clock), runId);
        jobs.put(libraryId, job);
        MetadataSyncJobResponse started = job.toResponse();
        worker.execute(() -> run(libraryId, ids, job, mode));
        return started;
    }

    /**
     * Resynchronises one book with all the sources, or with {@code source} only (queried again, and the only one
     * whose values are used).
     */
    public BookSyncResponse syncBook(CurrentUser user, Long bookId, SyncMode mode, LookupSource source) {
        requireAdmin(user);
        Snapshot snapshot = snapshot(user.libraryId(), bookId);
        if (snapshot.isbn13() == null) {
            throw new BadRequestException("Ce livre n'a pas d'ISBN : il ne peut pas être resynchronisé.");
        }
        Long runId = history.start(SyncKind.METADATA_BOOK, user.libraryId(), user.email(), 1);
        Result result;
        try {
            result = sync(user.libraryId(), bookId, snapshot, mode, source);
        } catch (RuntimeException e) {
            history.record(runId, snapshot.title(), SyncItemOutcome.FAILED, failure(e));
            history.finish(runId, false);
            throw e;
        }
        history.record(runId, snapshot.title(), itemOutcome(result.outcome()),
                describe(result, source == null ? null : source.name()));
        history.finish(runId, false);
        return new BookSyncResponse(result.outcome(), result.changedFields(), bookService.get(user, bookId));
    }

    private void run(Long libraryId, List<Long> ids, Job job, SyncMode mode) {
        try {
            for (Long id : ids) {
                if (Thread.currentThread().isInterrupted()) {
                    return;
                }
                syncInBackground(libraryId, id, job, mode);
                if (!pause.isZero()) {
                    Thread.sleep(pause);
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            job.finish(Instant.now(clock));
            history.finish(job.runId, Thread.currentThread().isInterrupted());
        }
    }

    private void syncInBackground(Long libraryId, Long id, Job job, SyncMode mode) {
        String label = "Livre n°" + id;
        SyncItemOutcome outcome;
        String detail;
        try {
            Snapshot snapshot = snapshot(libraryId, id);
            label = snapshot.title();
            if (snapshot.isbn13() == null) {
                outcome = SyncItemOutcome.UNCHANGED;
                detail = "Pas d'ISBN";
            } else {
                Result result = sync(libraryId, id, snapshot, mode, null);
                outcome = itemOutcome(result.outcome());
                detail = describe(result, null);
            }
        } catch (NotFoundException e) {
            outcome = SyncItemOutcome.UNCHANGED;
            detail = "Supprimé entre-temps";
        } catch (RuntimeException e) {
            if (!(e instanceof ServiceUnavailableException)) {
                log.warn("Resynchronisation of book {} failed", id, e);
            }
            outcome = SyncItemOutcome.FAILED;
            detail = failure(e);
        }
        switch (outcome) {
            case UPDATED -> job.updated.incrementAndGet();
            case NOT_FOUND -> job.notFound.incrementAndGet();
            case FAILED -> job.failed.incrementAndGet();
            default -> job.unchanged.incrementAndGet();
        }
        history.record(job.runId, label, outcome, detail);
    }

    private static SyncItemOutcome itemOutcome(SyncOutcome outcome) {
        return switch (outcome) {
            case UPDATED -> SyncItemOutcome.UPDATED;
            case UNCHANGED -> SyncItemOutcome.UNCHANGED;
            case NOT_FOUND -> SyncItemOutcome.NOT_FOUND;
        };
    }

    /** What the history says of a resynchronised book, in French. */
    static String describe(Result result, String source) {
        String from = source == null ? "" : " (source " + source + ")";
        return switch (result.outcome()) {
            case UPDATED -> "Modifié" + from + " : " + String.join(", ", result.changedFields().stream()
                    .map(field -> FIELD_LABELS.getOrDefault(field, field)).toList());
            case UNCHANGED -> "Rien à changer" + from;
            case NOT_FOUND -> "Aucune source ne connaît cet ISBN" + from;
        };
    }

    private static String failure(RuntimeException e) {
        return e instanceof ServiceUnavailableException && e.getMessage() != null ? e.getMessage()
                : "Erreur inattendue (" + e.getClass().getSimpleName() + ")";
    }

    private static final Map<String, String> FIELD_LABELS = Map.ofEntries(
            Map.entry("title", "titre"), Map.entry("subtitle", "sous-titre"), Map.entry("series", "série"),
            Map.entry("seriesNumber", "tome"), Map.entry("authors", "auteurs"), Map.entry("publisher", "éditeur"),
            Map.entry("year", "année"), Map.entry("pages", "pages"), Map.entry("language", "langue"),
            Map.entry("summary", "résumé"), Map.entry("cover", "couverture"));

    private Snapshot snapshot(Long libraryId, Long bookId) {
        return transaction.execute(status -> {
            Book book = books.findByLibraryIdAndBookId(libraryId, bookId).orElseThrow(NotFoundException::new).getBook();
            return new Snapshot(book.getIsbn13(), book.getCoverKey(), book.getTitle());
        });
    }

    private Result sync(Long libraryId, Long bookId, Snapshot snapshot, SyncMode mode, LookupSource source) {
        String isbn13 = snapshot.isbn13();
        Optional<BookMetadata> found = source == null
                ? lookups.refresh(isbn13, REUSE_RECENT_LOOKUPS).map(MetadataMerger.Merged::metadata)
                : lookups.refreshSource(isbn13, source);
        if (found.isEmpty()) {
            return new Result(SyncOutcome.NOT_FOUND, List.of());
        }
        if (mode == SyncMode.FETCH) {
            return new Result(SyncOutcome.UNCHANGED, List.of());
        }
        String coverKey = null;
        if (mode == SyncMode.REPLACE || snapshot.coverKey() == null) {
            coverKey = source == null ? covers.importFromIsbn(isbn13).orElse(null)
                    : Optional.ofNullable(found.get().coverUrl()).flatMap(covers::importFromUrl).orElse(null);
        }
        String cover = coverKey;
        return transaction.execute(status -> {
            Book book = books.findByLibraryIdAndBookId(libraryId, bookId).orElseThrow(NotFoundException::new).getBook();
            List<String> changed = apply(book, found.get(), cover, mode, null, seriesRegistry::place);
            return new Result(changed.isEmpty() ? SyncOutcome.UNCHANGED : SyncOutcome.UPDATED, changed);
        });
    }

    /** Copies the found values into the book; a value the sources do not know never erases the book's. */
    static List<String> apply(Book book, BookMetadata found, String coverKey, SyncMode mode) {
        return apply(book, found, coverKey, mode, null, MetadataSyncService::placeUnsaved);
    }

    /** Puts a book in a series that is not saved: for tests, which have no database. */
    static void placeUnsaved(Book book, String name, Integer number) {
        book.placeInSeries(name == null ? null : new Series(name, SeriesService.key(name)), number);
    }

    /** Puts a book in the series of a name (none when null), as volume {@code number}. */
    @FunctionalInterface
    interface SeriesPlacer {
        void place(Book book, String name, Integer number);
    }

    /**
     * Like {@link #apply(Book, BookMetadata, String, SyncMode)} for the named fields only ({@code only} null: all),
     * the series placed by {@code placer}.
     */
    static List<String> apply(Book book, BookMetadata found, String coverKey, SyncMode mode, Set<String> only,
            SeriesPlacer placer) {
        List<String> changed = new ArrayList<>();
        Field<String> text = (name, current, value, setter) -> {
            if (only == null || only.contains(name)) {
                update(changed, mode, name, current, value, setter);
            }
        };
        Field<Integer> number = (name, current, value, setter) -> {
            if (only == null || only.contains(name)) {
                update(changed, mode, name, current, value, setter);
            }
        };
        text.apply("title", book.getTitle(), limit(found.title(), 500), book::setTitle);
        text.apply("subtitle", book.getSubtitle(), limit(found.subtitle(), 500), book::setSubtitle);
        String[] series = {book.getSeriesName()};
        Integer[] seriesNumber = {book.getSeriesNumber()};
        text.apply("series", series[0], limit(found.series(), 300), value -> series[0] = value);
        number.apply("seriesNumber", seriesNumber[0], found.seriesNumber(), value -> seriesNumber[0] = value);
        if (changed.contains("series") || changed.contains("seriesNumber")) {
            placer.place(book, series[0], seriesNumber[0]);
        }
        text.apply("authors", book.getAuthors(), limit(found.authors(), 1000), book::setAuthors);
        text.apply("publisher", book.getPublisher(), limit(found.publisher(), 300), book::setPublisher);
        number.apply("year", book.getYear(), found.year(), book::setYear);
        number.apply("pages", book.getPages(), found.pages(), book::setPages);
        text.apply("language", book.getLanguage(), limit(found.language(), 10), book::setLanguage);
        text.apply("summary", book.getSummary(), limit(found.summary(), 20000), book::setSummary);
        text.apply("cover", book.getCoverKey(), coverKey, book::setCoverKey);
        return changed;
    }

    private static <T> void update(List<String> changed, SyncMode mode, String name, T current, T value,
            Consumer<T> setter) {
        boolean empty = current == null || (current instanceof String s && s.isBlank());
        if (value == null || Objects.equals(current, value) || (mode == SyncMode.FILL && !empty)) {
            return;
        }
        setter.accept(value);
        changed.add(name);
    }

    private static String limit(String value, int max) {
        return value == null || value.length() <= max ? value : value.substring(0, max);
    }

    private MetadataSyncJobResponse job(Long libraryId) {
        Job job = jobs.get(libraryId);
        return job == null ? new MetadataSyncJobResponse(SyncState.IDLE, 0, 0, 0, 0, 0, 0, null, null) : job.toResponse();
    }

    static void requireAdmin(CurrentUser user) {
        if (!user.admin()) {
            throw new ForbiddenException("Réservé à l'administrateur de l'application.");
        }
    }

    @FunctionalInterface
    private interface Field<T> {
        void apply(String name, T current, T value, Consumer<T> setter);
    }

    private record Snapshot(String isbn13, String coverKey, String title) {
    }

    record Result(SyncOutcome outcome, List<String> changedFields) {
    }

    /** Progress of a full resynchronisation, updated by the worker and read by the requests. */
    private static final class Job {
        private final int total;
        private final Instant startedAt;
        private final Long runId;
        private final AtomicInteger updated = new AtomicInteger();
        private final AtomicInteger unchanged = new AtomicInteger();
        private final AtomicInteger notFound = new AtomicInteger();
        private final AtomicInteger failed = new AtomicInteger();
        private volatile SyncState state = SyncState.RUNNING;
        private volatile Instant finishedAt;

        Job(int total, Instant startedAt, Long runId) {
            this.total = total;
            this.startedAt = startedAt;
            this.runId = runId;
        }

        void finish(Instant at) {
            finishedAt = at;
            state = SyncState.DONE;
        }

        MetadataSyncJobResponse toResponse() {
            int u = updated.get();
            int same = unchanged.get();
            int missing = notFound.get();
            int ko = failed.get();
            return new MetadataSyncJobResponse(state, total, u + same + missing + ko, u, same, missing, ko,
                    startedAt, finishedAt);
        }
    }
}
