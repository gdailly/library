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
 * What a synchronisation did with one book or one series: {@code label} is its title or name. The volumes listed for
 * a series are items too, under the series item ({@code parentId}); {@code childCount} counts them.
 */
@Entity
public class SyncRunItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long runId;

    private Long parentId;

    private int childCount;

    @Column(nullable = false)
    private String label;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SyncItemOutcome outcome;

    private String detail;

    @Column(nullable = false)
    private Instant createdAt;

    protected SyncRunItem() {
    }

    public SyncRunItem(Long runId, Long parentId, String label, SyncItemOutcome outcome, String detail,
            Instant createdAt) {
        this.runId = runId;
        this.parentId = parentId;
        this.label = label;
        this.outcome = outcome;
        this.detail = detail;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public Long getRunId() {
        return runId;
    }

    public Long getParentId() {
        return parentId;
    }

    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int childCount) {
        this.childCount = childCount;
    }

    public String getLabel() {
        return label;
    }

    public SyncItemOutcome getOutcome() {
        return outcome;
    }

    public String getDetail() {
        return detail;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
