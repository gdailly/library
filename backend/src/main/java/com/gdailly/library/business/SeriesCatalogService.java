package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.client.BnfClient.SeriesVolume;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.BookSeriesRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.SeriesRepository;

/**
 * Lists, in the background, every volume of the series the libraries hold, from the BnF catalogue: the series record
 * is the one a volume links to (zone 461 $0 of its cached BnF answer). Each volume listed becomes a book of the
 * series (the book of that ISBN when there is one), unless the series already has a book of that number. A series is
 * listed again after 30 days, and after 7 days when nothing was found.
 */
@Service
public class SeriesCatalogService {

    private static final Logger log = LoggerFactory.getLogger(SeriesCatalogService.class);

    static final Duration STALE_AFTER = Duration.ofDays(30);
    static final Duration RETRY_AFTER = Duration.ofDays(7);
    /** Series listed per run, so that a large library does not flood the BnF. */
    static final int PER_RUN = 20;

    private final BookRepository books;
    private final LibraryBookRepository entries;
    private final SeriesRepository seriesRepository;
    private final BookSeriesRepository links;
    private final IsbnLookupRepository isbnCache;
    private final BnfClient bnf;
    private final MetadataSources sources;
    private final SyncHistoryService history;
    private final TransactionTemplate transaction;
    private final Clock clock;
    private final Duration pause;

    SeriesCatalogService(BookRepository books, LibraryBookRepository entries, SeriesRepository seriesRepository,
            BookSeriesRepository links, IsbnLookupRepository isbnCache, BnfClient bnf, MetadataSources sources,
            SyncHistoryService history, PlatformTransactionManager transactionManager, Clock clock,
            @Value("${livre.series.pause:PT1S}") Duration pause) {
        this.books = books;
        this.entries = entries;
        this.seriesRepository = seriesRepository;
        this.links = links;
        this.isbnCache = isbnCache;
        this.bnf = bnf;
        this.sources = sources;
        this.history = history;
        this.transaction = new TransactionTemplate(transactionManager);
        this.clock = clock;
        this.pause = pause;
    }

    /** Lists the series never listed or listed too long ago, a few at a time. */
    @Scheduled(initialDelayString = "${livre.series.initial-delay:PT2M}", fixedDelayString = "${livre.series.refresh-delay:PT1H}")
    public void refreshStale() {
        Instant now = clock.instant();
        List<Series> due = heldSeries().stream()
                .filter(series -> isDue(series, now))
                // Never listed first, then the oldest.
                .sorted(Comparator.comparing((Series series) -> series.getFetchedAt() != null)
                        .thenComparing(series -> series.getFetchedAt() == null ? Instant.MIN : series.getFetchedAt()))
                .limit(PER_RUN)
                .toList();
        if (due.isEmpty()) {
            return;
        }
        Long runId = history.start(SyncKind.SERIES_SCHEDULED, null, null, due.size());
        boolean interrupted = false;
        try {
            for (Series series : due) {
                Refreshed refreshed;
                try {
                    refreshed = refresh(series.getId());
                } catch (RuntimeException e) {
                    // The BnF is unreachable or answered badly: the series is tried again at the next run.
                    log.warn("Listing the volumes of series '{}' failed: {}", series.getName(), e.toString());
                    refreshed = null;
                }
                record(runId, series.getName(), refreshed);
                Thread.sleep(pause);
            }
            log.info("Listed the volumes of {} series", due.size());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            interrupted = true;
        } finally {
            history.finish(runId, interrupted);
        }
    }

    /** The series of which some library holds or wishes a book, by name. */
    List<Series> heldSeries() {
        Map<Long, Series> found = new HashMap<>();
        transaction.executeWithoutResult(tx -> links.findHeld().forEach(link -> found.putIfAbsent(
                link.getSeries().getId(), link.getSeries())));
        return found.values().stream().sorted(Comparator.comparing(Series::getName, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    static boolean isDue(Series series, Instant now) {
        if (series.getFetchedAt() == null) {
            return true;
        }
        Duration age = series.getStatus() == SeriesCatalogStatus.FOUND ? STALE_AFTER : RETRY_AFTER;
        return series.getFetchedAt().plus(age).isBefore(now);
    }

    /** Writes in the history what listing a series gave, volume by volume; {@code refreshed} null when the BnF failed. */
    void record(Long runId, String label, Refreshed refreshed) {
        if (refreshed == null) {
            history.record(runId, label, SyncItemOutcome.FAILED, "La BnF n'a pas répondu");
            return;
        }
        List<SyncHistoryService.Child> children = volumeLines(refreshed);
        long added = children.stream().filter(c -> c.outcome() == SyncItemOutcome.ADDED).count();
        long removed = children.stream().filter(c -> c.outcome() == SyncItemOutcome.REMOVED).count();
        String changes = (added > 0 ? ", " + added + (added > 1 ? " nouveaux" : " nouveau") : "")
                + (removed > 0 ? ", " + removed + (removed > 1 ? " retirés" : " retiré") : "");
        int listed = refreshed.listed();
        switch (refreshed.status()) {
            case FOUND -> history.record(runId, label, SyncItemOutcome.FOUND,
                    listed + (listed > 1 ? " tomes listés" : " tome listé") + changes, children);
            case NOT_FOUND -> history.record(runId, label, SyncItemOutcome.NOT_FOUND,
                    "La notice BnF de la série ne liste aucun tome" + changes, children);
            case NO_REFERENCE -> history.record(runId, label, SyncItemOutcome.NO_REFERENCE,
                    "Aucun livre de la série n'est rattaché à une notice de série BnF" + changes, children);
        }
    }

    /**
     * One line per volume of the series after the listing (ADDED when the series had no book of that number before,
     * UNCHANGED otherwise) or before it only (REMOVED), by number, saying whether a library holds it.
     */
    static List<SyncHistoryService.Child> volumeLines(Refreshed refreshed) {
        Map<Integer, SeriesVolume> before = byNumber(refreshed.previous());
        Map<Integer, SeriesVolume> now = byNumber(refreshed.volumes());
        SortedSet<Integer> numbers = new TreeSet<>(now.keySet());
        numbers.addAll(before.keySet());
        List<SyncHistoryService.Child> lines = new ArrayList<>();
        for (Integer number : numbers) {
            SeriesVolume volume = now.containsKey(number) ? now.get(number) : before.get(number);
            SyncItemOutcome outcome = !now.containsKey(number) ? SyncItemOutcome.REMOVED
                    : before.containsKey(number) ? SyncItemOutcome.UNCHANGED : SyncItemOutcome.ADDED;
            List<String> facts = new ArrayList<>();
            if (volume.isbn13() != null) {
                facts.add("ISBN " + volume.isbn13());
            }
            if (volume.year() != null) {
                facts.add(String.valueOf(volume.year()));
            }
            Boolean owned = refreshed.held().get(number);
            facts.add(owned == null ? "manquant dans la bibliothèque" : owned ? "possédé" : "dans les envies");
            lines.add(new SyncHistoryService.Child("Tome " + number + " · " + volume.title(), outcome,
                    String.join(" · ", facts)));
        }
        return lines;
    }

    private static Map<Integer, SeriesVolume> byNumber(List<SeriesVolume> volumes) {
        Map<Integer, SeriesVolume> map = new TreeMap<>();
        volumes.forEach(volume -> map.putIfAbsent(volume.number(), volume));
        return map;
    }

    /**
     * Lists the volumes of one series from the BnF and updates its books: a volume the series has no book of becomes
     * one (or links the book of its ISBN); a book only the BnF knew that it no longer lists leaves the series, and is
     * deleted when nothing else needs it. Books a library holds are never removed. One series at a time, so that the
     * scheduled run and a refresh forced by the administrator do not write the same series together.
     */
    synchronized Refreshed refresh(Long seriesId) {
        List<String> isbns = transaction.execute(tx -> links.findBySeriesIds(List.of(seriesId)).stream()
                .map(link -> link.getBook().getIsbn13()).filter(Objects::nonNull).distinct().toList());
        Optional<String> ref = seriesRef(isbns);
        List<SeriesVolume> chosen = choose(ref.map(bnf::fetchSeriesVolumes).orElse(List.of()));
        SeriesCatalogStatus status = ref.isEmpty() ? SeriesCatalogStatus.NO_REFERENCE
                : chosen.isEmpty() ? SeriesCatalogStatus.NOT_FOUND : SeriesCatalogStatus.FOUND;
        Instant now = clock.instant();
        return transaction.execute(tx -> {
            Series series = seriesRepository.findById(seriesId).orElseThrow();
            series.listed(status, ref.orElse(null), now);
            List<BookSeries> current = links.findBySeriesIds(List.of(seriesId));
            List<SeriesVolume> previous = volumesOf(current);
            Set<Long> heldIds = new HashSet<>();
            entries.findByBookIdIn(current.stream().map(link -> link.getBook().getId()).toList())
                    .forEach(entry -> heldIds.add(entry.getBook().getId()));
            Set<Integer> listedNumbers = new HashSet<>();
            Set<Integer> covered = new HashSet<>();
            current.forEach(link -> covered.add(link.getNumber()));
            for (SeriesVolume volume : chosen) {
                listedNumbers.add(volume.number());
                if (!covered.contains(volume.number())) {
                    add(series, volume);
                    covered.add(volume.number());
                }
            }
            for (BookSeries link : current) {
                Book book = link.getBook();
                if (!heldIds.contains(book.getId()) && !listedNumbers.contains(link.getNumber())) {
                    book.getSeriesLinks().remove(link);
                    if (book.getSeriesLinks().isEmpty()) {
                        books.delete(book);
                    }
                }
            }
            books.flush();
            List<BookSeries> after = links.findBySeriesIds(List.of(seriesId));
            Map<Integer, Boolean> held = new TreeMap<>();
            entries.findByBookIdIn(after.stream().map(link -> link.getBook().getId()).toList()).forEach(entry -> {
                Integer number = after.stream().filter(link -> link.getBook().getId().equals(entry.getBook().getId()))
                        .map(BookSeries::getNumber).filter(Objects::nonNull).findFirst().orElse(null);
                if (number != null) {
                    held.merge(number, entry.isOwned(), Boolean::logicalOr);
                }
            });
            return new Refreshed(status, chosen.size(), volumesOf(after), previous, held);
        });
    }

    /** A volume listed by the BnF joins the series: the book of its ISBN when there is one, else a new book. */
    private void add(Series series, SeriesVolume volume) {
        Book book = volume.isbn13() == null ? null : books.findByIsbn13(volume.isbn13()).orElse(null);
        if (book == null) {
            book = new Book();
            book.setIsbn13(volume.isbn13());
            book.setTitle(volume.title());
            book.setYear(volume.year());
            book = books.save(book);
        } else if (book.getSeriesLinks().stream()
                .anyMatch(link -> link.getSeries().getId().equals(series.getId()) && link.getNumber() != null)) {
            return;
        }
        Book target = book;
        target.getSeriesLinks().removeIf(link -> link.getSeries().getId().equals(series.getId()));
        target.getSeriesLinks().add(new BookSeries(target, series, volume.number()));
    }

    /** The numbered books of a series as volumes, one per number (the first by id). */
    private static List<SeriesVolume> volumesOf(List<BookSeries> seriesLinks) {
        Map<Integer, SeriesVolume> volumes = new TreeMap<>();
        seriesLinks.stream()
                .filter(link -> link.getNumber() != null)
                .sorted(Comparator.comparing(link -> link.getBook().getId()))
                .forEach(link -> volumes.putIfAbsent(link.getNumber(), new SeriesVolume(link.getNumber(),
                        link.getBook().getTitle(), link.getBook().getIsbn13(), link.getBook().getYear())));
        return List.copyOf(volumes.values());
    }

    /**
     * How listing a series went: how many volumes the BnF listed, the numbered volumes of the series after and before,
     * and for each number held by a library, whether one owns it (true) or only wishes it.
     */
    record Refreshed(SeriesCatalogStatus status, int listed, List<SeriesVolume> volumes, List<SeriesVolume> previous,
            Map<Integer, Boolean> held) {
    }

    /** The BnF series record linked by the cached answer of a volume of the series. */
    private Optional<String> seriesRef(List<String> isbns) {
        return isbnCache.findAllById(isbns).stream()
                .map(this::bnfPayload)
                .map(BnfClient::seriesRef)
                .filter(Objects::nonNull)
                .findFirst();
    }

    private String bnfPayload(IsbnLookup entry) {
        return sources.rawPayloads(entry).get(LookupSource.BNF);
    }

    /** One record per volume number: the one with an ISBN, then the most recent printing. */
    static List<SeriesVolume> choose(List<SeriesVolume> found) {
        Map<Integer, SeriesVolume> best = new TreeMap<>();
        Comparator<SeriesVolume> better = Comparator
                .comparing((SeriesVolume v) -> v.isbn13() != null)
                .thenComparing(v -> v.year() == null ? Integer.MIN_VALUE : v.year());
        for (SeriesVolume volume : found) {
            Integer number = volume.number();
            if (number == null || number < 1 || number > SeriesService.MAX_LISTED_NUMBER) {
                continue;
            }
            best.merge(number, volume, (a, b) -> better.compare(b, a) > 0 ? b : a);
        }
        List<SeriesVolume> chosen = new ArrayList<>();
        best.forEach((number, v) -> chosen.add(new SeriesVolume(number, limit(v.title(), 500), v.isbn13(), v.year())));
        return chosen;
    }

    private static String limit(String value, int max) {
        return value.length() <= max ? value : value.substring(0, max);
    }
}
