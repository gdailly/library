package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.dto.SyncRunItemResponse;
import com.gdailly.library.dto.SyncRunResponse;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.entity.SyncRun;
import com.gdailly.library.entity.SyncRunItem;
import com.gdailly.library.entity.SyncRunState;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.SyncRunMapper;
import com.gdailly.library.repository.SyncRunItemRepository;
import com.gdailly.library.repository.SyncRunRepository;
import com.gdailly.library.security.CurrentUser;

/**
 * History of the synchronisations, written as they progress so that the administrator can follow a running one and
 * look back at what happened. Entries older than {@code livre.sync-history.retention} (30 days) are deleted every
 * night. Writing the history never makes a synchronisation fail.
 */
@Service
public class SyncHistoryService {

    private static final Logger log = LoggerFactory.getLogger(SyncHistoryService.class);
    static final int RUNS_PER_PAGE = 20;
    static final int ITEMS_PER_PAGE = 50;
    private static final Set<SyncItemOutcome> PROBLEMS = EnumSet.of(SyncItemOutcome.NOT_FOUND,
            SyncItemOutcome.NO_REFERENCE, SyncItemOutcome.FAILED);

    private final SyncRunRepository runs;
    private final SyncRunItemRepository items;
    private final SyncRunMapper mapper;
    private final Clock clock;
    private final Duration retention;

    SyncHistoryService(SyncRunRepository runs, SyncRunItemRepository items, SyncRunMapper mapper, Clock clock,
            @Value("${livre.sync-history.retention:P30D}") Duration retention) {
        this.runs = runs;
        this.items = items;
        this.mapper = mapper;
        this.clock = clock;
        this.retention = retention;
    }

    /** Records the start of a synchronisation of {@code total} items; null if the history could not be written. */
    @Transactional
    public Long start(SyncKind kind, Long libraryId, String startedBy, int total) {
        try {
            return runs.save(new SyncRun(kind, libraryId, startedBy, total, clock.instant())).getId();
        } catch (RuntimeException e) {
            log.warn("Could not record the start of a {} synchronisation: {}", kind, e.toString());
            return null;
        }
    }

    /** One line under an item: a volume listed for a series. */
    public record Child(String label, SyncItemOutcome outcome, String detail) {
    }

    /** Records what a synchronisation did with one item and counts it. */
    @Transactional
    public void record(Long runId, String label, SyncItemOutcome outcome, String detail) {
        record(runId, label, outcome, detail, List.of());
    }

    /** Like {@link #record(Long, String, SyncItemOutcome, String)}, with the lines under the item (not counted). */
    @Transactional
    public void record(Long runId, String label, SyncItemOutcome outcome, String detail, List<Child> children) {
        if (runId == null) {
            return;
        }
        try {
            runs.findById(runId).ifPresent(run -> {
                run.count(outcome);
                Instant now = clock.instant();
                SyncRunItem item = new SyncRunItem(runId, null, limit(label, 500), outcome, limit(detail, 1000), now);
                item.setChildCount(children.size());
                Long parentId = items.save(item).getId();
                items.saveAll(children.stream()
                        .map(child -> new SyncRunItem(runId, parentId, limit(child.label(), 500), child.outcome(),
                                limit(child.detail(), 1000), now))
                        .toList());
            });
        } catch (RuntimeException e) {
            log.warn("Could not record an item of synchronisation {}: {}", runId, e.toString());
        }
    }

    /** Records the end of a synchronisation: DONE, or INTERRUPTED when the server stopped it. */
    @Transactional
    public void finish(Long runId, boolean interrupted) {
        if (runId == null) {
            return;
        }
        try {
            runs.findById(runId).ifPresent(run -> run.finish(interrupted ? SyncRunState.INTERRUPTED : SyncRunState.DONE,
                    clock.instant()));
        } catch (RuntimeException e) {
            log.warn("Could not record the end of synchronisation {}: {}", runId, e.toString());
        }
    }

    /** A synchronisation still RUNNING at startup was stopped with the previous server. */
    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void interruptLeftovers() {
        int interrupted = runs.interruptRunning(SyncRunState.RUNNING, SyncRunState.INTERRUPTED, clock.instant());
        if (interrupted > 0) {
            log.info("Marked {} synchronisation(s) left running as interrupted", interrupted);
        }
    }

    /** Deletes the history older than the retention, every night. */
    @Scheduled(cron = "${livre.sync-history.purge-cron:0 30 3 * * *}")
    @Transactional
    public int purge() {
        int deleted = runs.deleteFinishedBefore(clock.instant().minus(retention), SyncRunState.RUNNING);
        if (deleted > 0) {
            log.info("Deleted {} synchronisation(s) older than {}", deleted, retention);
        }
        return deleted;
    }

    /** The synchronisations, most recent first. */
    @Transactional(readOnly = true)
    public PageResponse<SyncRunResponse> list(CurrentUser user, int page) {
        MetadataSyncService.requireAdmin(user);
        return PageResponse.of(runs.findAllByOrderByStartedAtDescIdDesc(PageRequest.of(page, RUNS_PER_PAGE)),
                mapper::toResponse);
    }

    @Transactional(readOnly = true)
    public SyncRunResponse get(CurrentUser user, Long id) {
        MetadataSyncService.requireAdmin(user);
        return runs.findById(id).map(mapper::toResponse).orElseThrow(NotFoundException::new);
    }

    /** The items of a synchronisation, most recent first; only those not found or failed with {@code problemsOnly}. */
    @Transactional(readOnly = true)
    public PageResponse<SyncRunItemResponse> items(CurrentUser user, Long id, boolean problemsOnly, int page) {
        MetadataSyncService.requireAdmin(user);
        if (!runs.existsById(id)) {
            throw new NotFoundException();
        }
        Pageable pageable = PageRequest.of(page, ITEMS_PER_PAGE);
        return PageResponse.of(problemsOnly
                ? items.findByRunIdAndParentIdIsNullAndOutcomeInOrderByIdDesc(id, PROBLEMS, pageable)
                : items.findByRunIdAndParentIdIsNullOrderByIdDesc(id, pageable), mapper::toResponse);
    }

    /** The lines under an item of a synchronisation: the volumes listed for a series, in order. */
    @Transactional(readOnly = true)
    public List<SyncRunItemResponse> children(CurrentUser user, Long id, Long itemId) {
        MetadataSyncService.requireAdmin(user);
        if (!runs.existsById(id)) {
            throw new NotFoundException();
        }
        return items.findByRunIdAndParentIdOrderByIdAsc(id, itemId).stream().map(mapper::toResponse).toList();
    }

    private static String limit(String value, int max) {
        if (value == null) {
            return null;
        }
        String trimmed = value.strip();
        return trimmed.length() <= max ? trimmed : trimmed.substring(0, max);
    }
}
