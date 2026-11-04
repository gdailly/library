package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.SeriesCatalog;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.entity.SeriesVolume;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.repository.SeriesCatalogRepository;
import com.gdailly.library.repository.SeriesVolumeRepository;

/**
 * Lists, in the background, every volume of the series the libraries hold, from the BnF catalogue: the series record
 * is the one a volume links to (zone 461 $0 of its cached BnF answer). A series is listed again after 30 days, and
 * after 7 days when nothing was found.
 */
@Service
public class SeriesCatalogService {

    private static final Logger log = LoggerFactory.getLogger(SeriesCatalogService.class);

    static final Duration STALE_AFTER = Duration.ofDays(30);
    static final Duration RETRY_AFTER = Duration.ofDays(7);
    /** Series listed per run, so that a large library does not flood the BnF. */
    static final int PER_RUN = 20;

    private final BookRepository books;
    private final IsbnLookupRepository isbnCache;
    private final SeriesCatalogRepository catalogs;
    private final SeriesVolumeRepository volumes;
    private final BnfClient bnf;
    private final MetadataSources sources;
    private final SyncHistoryService history;
    private final TransactionTemplate transaction;
    private final Clock clock;
    private final Duration pause;

    SeriesCatalogService(BookRepository books, IsbnLookupRepository isbnCache, SeriesCatalogRepository catalogs,
            SeriesVolumeRepository volumes, BnfClient bnf, MetadataSources sources, SyncHistoryService history,
            PlatformTransactionManager transactionManager, Clock clock,
            @Value("${livre.series.pause:PT1S}") Duration pause) {
        this.books = books;
        this.isbnCache = isbnCache;
        this.catalogs = catalogs;
        this.volumes = volumes;
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
        Map<String, List<Book>> bySeries = seriesBooks();
        Map<String, SeriesCatalog> known = catalogs.findAllById(bySeries.keySet()).stream()
                .collect(Collectors.toMap(SeriesCatalog::getSeriesKey, c -> c));
        Instant now = clock.instant();
        List<String> due = bySeries.keySet().stream()
                .filter(key -> isDue(known.get(key), now))
                // Never listed first, then the oldest.
                .sorted(Comparator.comparing((String key) -> known.containsKey(key))
                        .thenComparing(key -> known.containsKey(key) ? known.get(key).getFetchedAt() : Instant.MIN))
                .limit(PER_RUN)
                .toList();
        if (due.isEmpty()) {
            return;
        }
        Long runId = history.start(SyncKind.SERIES_SCHEDULED, null, null, due.size());
        boolean interrupted = false;
        try {
            for (String key : due) {
                List<Book> members = bySeries.get(key);
                Refreshed refreshed;
                try {
                    refreshed = refresh(key, members);
                } catch (RuntimeException e) {
                    // The BnF is unreachable or answered badly: the series is tried again at the next run.
                    log.warn("Listing the volumes of series '{}' failed: {}", key, e.toString());
                    refreshed = null;
                }
                record(runId, members, refreshed);
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

    /** Writes in the history what listing a series gave, volume by volume; {@code refreshed} null when the BnF failed. */
    void record(Long runId, List<Book> members, Refreshed refreshed) {
        String label = members.getFirst().getSeries();
        if (refreshed == null) {
            history.record(runId, label, SyncItemOutcome.FAILED, "La BnF n'a pas répondu");
            return;
        }
        List<SyncHistoryService.Child> children = volumeLines(members, refreshed);
        long added = children.stream().filter(c -> c.outcome() == SyncItemOutcome.ADDED).count();
        long removed = children.stream().filter(c -> c.outcome() == SyncItemOutcome.REMOVED).count();
        String changes = (added > 0 ? ", " + added + (added > 1 ? " nouveaux" : " nouveau") : "")
                + (removed > 0 ? ", " + removed + (removed > 1 ? " retirés" : " retiré") : "");
        int listed = refreshed.volumes().size();
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
     * One line per volume listed now (ADDED when it was not listed before, UNCHANGED otherwise) or listed before only
     * (REMOVED), by number, saying whether a library holds it.
     */
    static List<SyncHistoryService.Child> volumeLines(List<Book> members, Refreshed refreshed) {
        Map<Integer, SeriesVolume> before = refreshed.previous().stream()
                .collect(Collectors.toMap(SeriesVolume::getNumber, v -> v, (a, b) -> a, TreeMap::new));
        Map<Integer, SeriesVolume> now = refreshed.volumes().stream()
                .collect(Collectors.toMap(SeriesVolume::getNumber, v -> v, (a, b) -> a, TreeMap::new));
        Map<Integer, Boolean> held = new TreeMap<>();
        for (Book book : members) {
            if (book.getSeriesNumber() != null) {
                held.merge(book.getSeriesNumber(), book.isOwned(), Boolean::logicalOr);
            }
        }
        SortedSet<Integer> numbers = new TreeSet<>(now.keySet());
        numbers.addAll(before.keySet());
        List<SyncHistoryService.Child> lines = new ArrayList<>();
        for (Integer number : numbers) {
            SeriesVolume volume = now.containsKey(number) ? now.get(number) : before.get(number);
            SyncItemOutcome outcome = !now.containsKey(number) ? SyncItemOutcome.REMOVED
                    : before.containsKey(number) ? SyncItemOutcome.UNCHANGED : SyncItemOutcome.ADDED;
            List<String> facts = new ArrayList<>();
            if (volume.getIsbn13() != null) {
                facts.add("ISBN " + volume.getIsbn13());
            }
            if (volume.getYear() != null) {
                facts.add(String.valueOf(volume.getYear()));
            }
            Boolean owned = held.get(number);
            facts.add(owned == null ? "manquant dans la bibliothèque" : owned ? "possédé" : "dans les envies");
            lines.add(new SyncHistoryService.Child("Tome " + number + " · " + volume.getTitle(), outcome,
                    String.join(" · ", facts)));
        }
        return lines;
    }

    /** The books of every library that belong to a series, by series key. */
    Map<String, List<Book>> seriesBooks() {
        return books.findAllWithSeries().stream()
                .filter(book -> !SeriesService.key(book.getSeries()).isEmpty())
                .collect(Collectors.groupingBy(book -> SeriesService.key(book.getSeries()), LinkedHashMap::new,
                        Collectors.toList()));
    }

    static boolean isDue(SeriesCatalog catalog, Instant now) {
        if (catalog == null) {
            return true;
        }
        Duration age = catalog.getStatus() == SeriesCatalogStatus.FOUND ? STALE_AFTER : RETRY_AFTER;
        return catalog.getFetchedAt().plus(age).isBefore(now);
    }

    /**
     * Lists the volumes of one series and replaces what was known of it. One series at a time, so that the scheduled
     * run and a refresh forced by the administrator do not write the same series together.
     */
    synchronized Refreshed refresh(String key, List<Book> members) {
        Optional<String> ref = seriesRef(members);
        List<BnfClient.SeriesVolume> found = ref.map(bnf::fetchSeriesVolumes).orElse(List.of());
        List<SeriesVolume> chosen = choose(key, found);
        SeriesCatalogStatus status = ref.isEmpty() ? SeriesCatalogStatus.NO_REFERENCE
                : chosen.isEmpty() ? SeriesCatalogStatus.NOT_FOUND : SeriesCatalogStatus.FOUND;
        // Read apart from the write below: the deleted entities must not stay in the persistence context.
        List<SeriesVolume> previous = volumes.findBySeriesKeyOrderByNumber(key);
        Instant now = clock.instant();
        transaction.executeWithoutResult(tx -> {
            SeriesCatalog catalog = catalogs.findById(key).orElse(null);
            if (catalog == null) {
                catalogs.save(new SeriesCatalog(key, status, ref.orElse(null), now));
            } else {
                catalog.update(status, ref.orElse(null), now);
            }
            volumes.deleteBySeriesKey(key);
            volumes.flush();
            volumes.saveAll(chosen);
        });
        return new Refreshed(status, chosen, previous);
    }

    /** How listing a series went, the volumes the BnF lists now and those it listed before. */
    record Refreshed(SeriesCatalogStatus status, List<SeriesVolume> volumes, List<SeriesVolume> previous) {
    }

    /** The BnF series record linked by the cached answer of a volume of the series. */
    private Optional<String> seriesRef(List<Book> members) {
        List<String> isbns = members.stream().map(Book::getIsbn13).filter(Objects::nonNull).distinct().toList();
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
    static List<SeriesVolume> choose(String key, List<BnfClient.SeriesVolume> found) {
        Map<Integer, BnfClient.SeriesVolume> best = new TreeMap<>();
        Comparator<BnfClient.SeriesVolume> better = Comparator
                .comparing((BnfClient.SeriesVolume v) -> v.isbn13() != null)
                .thenComparing(v -> v.year() == null ? Integer.MIN_VALUE : v.year());
        for (BnfClient.SeriesVolume volume : found) {
            Integer number = volume.number();
            if (number == null || number < 1 || number > SeriesService.MAX_LISTED_NUMBER) {
                continue;
            }
            best.merge(number, volume, (a, b) -> better.compare(b, a) > 0 ? b : a);
        }
        List<SeriesVolume> chosen = new ArrayList<>();
        best.forEach((number, v) -> chosen.add(new SeriesVolume(key, number, limit(v.title(), 500), v.isbn13(), v.year())));
        return chosen;
    }

    private static String limit(String value, int max) {
        return value.length() <= max ? value : value.substring(0, max);
    }
}
