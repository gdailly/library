package com.gdailly.library.entity;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/**
 * One synchronisation and its counters, updated as it progresses: {@code processed} = {@code succeeded} (books
 * updated, series found) + {@code unchanged} + {@code notFound} + {@code failed}. {@code startedBy} is the e-mail of
 * the administrator who started it, null for the scheduled runs; {@code libraryId} is null for the series, which
 * every library shares.
 */
@Entity
public class SyncRun {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SyncKind kind;

    private Long libraryId;

    private String startedBy;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SyncRunState state;

    private int total;
    private int processed;
    private int succeeded;
    private int unchanged;
    private int notFound;
    private int failed;

    @Column(nullable = false)
    private Instant startedAt;

    private Instant finishedAt;

    protected SyncRun() {
    }

    public SyncRun(SyncKind kind, Long libraryId, String startedBy, int total, Instant startedAt) {
        this.kind = kind;
        this.libraryId = libraryId;
        this.startedBy = startedBy;
        this.total = total;
        this.startedAt = startedAt;
        this.state = SyncRunState.RUNNING;
    }

    /** Counts one processed item under its outcome. */
    public void count(SyncItemOutcome outcome) {
        processed++;
        switch (outcome) {
            case UPDATED, FOUND -> succeeded++;
            case UNCHANGED -> unchanged++;
            case NOT_FOUND, NO_REFERENCE -> notFound++;
            case FAILED -> failed++;
        }
    }

    public void finish(SyncRunState state, Instant at) {
        this.state = state;
        this.finishedAt = at;
    }

    public Long getId() {
        return id;
    }

    public SyncKind getKind() {
        return kind;
    }

    public Long getLibraryId() {
        return libraryId;
    }

    public String getStartedBy() {
        return startedBy;
    }

    public SyncRunState getState() {
        return state;
    }

    public int getTotal() {
        return total;
    }

    public int getProcessed() {
        return processed;
    }

    public int getSucceeded() {
        return succeeded;
    }

    public int getUnchanged() {
        return unchanged;
    }

    public int getNotFound() {
        return notFound;
    }

    public int getFailed() {
        return failed;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public Instant getFinishedAt() {
        return finishedAt;
    }
}
