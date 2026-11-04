package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.gdailly.library.dto.SeriesDetailResponse;
import com.gdailly.library.dto.SeriesSyncJobResponse;
import com.gdailly.library.dto.SyncState;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.security.CurrentUser;

import jakarta.annotation.PreDestroy;

/**
 * Lets the administrator list the volumes of the series again without waiting for the scheduled run: every series
 * in the background, or one series right away.
 */
@Service
public class SeriesSyncService {

    private static final Logger log = LoggerFactory.getLogger(SeriesSyncService.class);

    private final SeriesCatalogService catalog;
    private final SeriesService series;
    private final BookRepository books;
    private final SyncHistoryService history;
    private final Clock clock;
    private final Duration pause;
    private final ExecutorService worker = Executors.newSingleThreadExecutor(Thread.ofVirtual().name("series-sync").factory());
    private volatile Job job;

    SeriesSyncService(SeriesCatalogService catalog, SeriesService series, BookRepository books, SyncHistoryService history,
            Clock clock,
            @Value("${livre.series.pause:PT1S}") Duration pause) {
        this.catalog = catalog;
        this.series = series;
        this.books = books;
        this.history = history;
        this.clock = clock;
        this.pause = pause;
    }

    @PreDestroy
    void stop() {
        worker.shutdownNow();
    }

    /** Progress of the forced listing of every series. */
    public SeriesSyncJobResponse status(CurrentUser user) {
        MetadataSyncService.requireAdmin(user);
        Job current = job;
        return current == null ? new SeriesSyncJobResponse(SyncState.IDLE, 0, 0, 0, 0, 0, null, null) : current.toResponse();
    }

    /** Starts listing again every series of every library, however recently it was listed; 409 if one is running. */
    public synchronized SeriesSyncJobResponse startAll(CurrentUser user) {
        MetadataSyncService.requireAdmin(user);
        if (job != null && job.state == SyncState.RUNNING) {
            throw new ConflictException("Une synchronisation des séries est déjà en cours.");
        }
        Map<String, List<Book>> bySeries = catalog.seriesBooks();
        Long runId = history.start(SyncKind.SERIES_ALL, null, user.email(), bySeries.size());
        Job started = new Job(bySeries.size(), clock.instant(), runId);
        job = started;
        SeriesSyncJobResponse response = started.toResponse();
        worker.execute(() -> run(bySeries, started));
        return response;
    }

    /** Lists the volumes of one series of the library now; 404 if it has no book of it, 503 if the BnF fails. */
    public SeriesDetailResponse syncOne(CurrentUser user, String name) {
        MetadataSyncService.requireAdmin(user);
        String key = SeriesService.key(name);
        List<Book> members = books.findByLibraryIdAndSeriesIsNotNull(user.libraryId()).stream()
                .filter(book -> SeriesService.key(book.getSeries()).equals(key))
                .toList();
        if (key.isEmpty() || members.isEmpty()) {
            throw new NotFoundException();
        }
        Long runId = history.start(SyncKind.SERIES_ONE, user.libraryId(), user.email(), 1);
        try {
            catalog.record(runId, members, catalog.refresh(key, members));
        } catch (RuntimeException e) {
            log.warn("Listing the volumes of series '{}' failed: {}", key, e.toString());
            catalog.record(runId, members, null);
            throw new ServiceUnavailableException("La BnF n'a pas répondu, réessaie plus tard.");
        } finally {
            history.finish(runId, false);
        }
        return series.detail(user, name);
    }

    private void run(Map<String, List<Book>> bySeries, Job current) {
        try {
            for (Map.Entry<String, List<Book>> entry : bySeries.entrySet()) {
                if (Thread.currentThread().isInterrupted()) {
                    return;
                }
                SeriesCatalogService.Refreshed refreshed = null;
                try {
                    refreshed = catalog.refresh(entry.getKey(), entry.getValue());
                    (refreshed.status() == SeriesCatalogStatus.FOUND ? current.found : current.notFound).incrementAndGet();
                } catch (RuntimeException e) {
                    current.failed.incrementAndGet();
                    log.warn("Listing the volumes of series '{}' failed: {}", entry.getKey(), e.toString());
                }
                catalog.record(current.runId, entry.getValue(), refreshed);
                if (!pause.isZero()) {
                    Thread.sleep(pause);
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            current.finish(clock.instant());
            history.finish(current.runId, Thread.currentThread().isInterrupted());
            log.info("Forced listing of {} series: {} found", current.total, current.found.get());
        }
    }

    private static final class Job {
        private final int total;
        private final Instant startedAt;
        private final Long runId;
        private final AtomicInteger found = new AtomicInteger();
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

        SeriesSyncJobResponse toResponse() {
            int f = found.get();
            int n = notFound.get();
            int x = failed.get();
            return new SeriesSyncJobResponse(state, total, f + n + x, f, n, x, startedAt, finishedAt);
        }
    }
}
