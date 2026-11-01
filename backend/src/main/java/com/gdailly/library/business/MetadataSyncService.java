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
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.repository.BookRepository;
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

    private final BookRepository books;
    private final IsbnLookupRepository isbnCache;
    private final IsbnLookupService lookups;
    private final CoverService covers;
    private final BookService bookService;
    private final TransactionTemplate transaction;
    private final Clock clock;
    private final Duration pause;
    private final ExecutorService worker = Executors.newSingleThreadExecutor(Thread.ofVirtual().name("metadata-sync").factory());
    private final Map<Long, Job> jobs = new ConcurrentHashMap<>();

    MetadataSyncService(BookRepository books, IsbnLookupRepository isbnCache, IsbnLookupService lookups,
            CoverService covers, BookService bookService, PlatformTransactionManager transactionManager, Clock clock,
            LivreProperties properties) {
        this.books = books;
        this.isbnCache = isbnCache;
        this.lookups = lookups;
        this.covers = covers;
        this.bookService = bookService;
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
                books.findIdsWithIsbn(user.libraryId()).size(),
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
        List<Long> ids = transaction.execute(status -> books.findIdsWithIsbn(libraryId));
        Job job = new Job(ids.size(), Instant.now(clock));
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
        Result result = sync(user.libraryId(), bookId, snapshot, mode, source);
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
        }
    }

    private void syncInBackground(Long libraryId, Long id, Job job, SyncMode mode) {
        try {
            Snapshot snapshot = snapshot(libraryId, id);
            if (snapshot.isbn13() == null) {
                job.unchanged.incrementAndGet();
                return;
            }
            switch (sync(libraryId, id, snapshot, mode, null).outcome()) {
                case UPDATED -> job.updated.incrementAndGet();
                case UNCHANGED -> job.unchanged.incrementAndGet();
                case NOT_FOUND -> job.notFound.incrementAndGet();
            }
        } catch (NotFoundException e) {
            job.unchanged.incrementAndGet(); // deleted meanwhile
        } catch (ServiceUnavailableException e) {
            job.failed.incrementAndGet();
        } catch (RuntimeException e) {
            job.failed.incrementAndGet();
            log.warn("Resynchronisation of book {} failed", id, e);
        }
    }

    private Snapshot snapshot(Long libraryId, Long bookId) {
        return transaction.execute(status -> {
            Book book = books.findByIdAndLibraryId(bookId, libraryId).orElseThrow(NotFoundException::new);
            return new Snapshot(book.getIsbn13(), book.getCoverKey());
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
            Book book = books.findByIdAndLibraryId(bookId, libraryId).orElseThrow(NotFoundException::new);
            List<String> changed = apply(book, found.get(), cover, mode, null);
            return new Result(changed.isEmpty() ? SyncOutcome.UNCHANGED : SyncOutcome.UPDATED, changed);
        });
    }

    /** Copies the found values into the book; a value the sources do not know never erases the book's. */
    static List<String> apply(Book book, BookMetadata found, String coverKey, SyncMode mode) {
        return apply(book, found, coverKey, mode, null);
    }

    /** Like {@link #apply(Book, BookMetadata, String, SyncMode)} for the named fields only ({@code only} null: all). */
    static List<String> apply(Book book, BookMetadata found, String coverKey, SyncMode mode, Set<String> only) {
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

    private record Snapshot(String isbn13, String coverKey) {
    }

    private record Result(SyncOutcome outcome, List<String> changedFields) {
    }

    /** Progress of a full resynchronisation, updated by the worker and read by the requests. */
    private static final class Job {
        private final int total;
        private final Instant startedAt;
        private final AtomicInteger updated = new AtomicInteger();
        private final AtomicInteger unchanged = new AtomicInteger();
        private final AtomicInteger notFound = new AtomicInteger();
        private final AtomicInteger failed = new AtomicInteger();
        private volatile SyncState state = SyncState.RUNNING;
        private volatile Instant finishedAt;

        Job(int total, Instant startedAt) {
            this.total = total;
            this.startedAt = startedAt;
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
