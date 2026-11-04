package com.gdailly.library.dto;

import java.time.Instant;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.entity.SyncRunState;

/**
 * A synchronisation of the history: {@code total} items, of which {@code processed} are done ({@code succeeded}:
 * books updated or series found at the BnF, + {@code unchanged} + {@code notFound} + {@code failed}).
 * {@code startedBy} is null for the scheduled runs.
 */
public record SyncRunResponse(
        long id,
        SyncKind kind,
        @Nullable String startedBy,
        SyncRunState state,
        int total,
        int processed,
        int succeeded,
        int unchanged,
        int notFound,
        int failed,
        Instant startedAt,
        @Nullable Instant finishedAt) {
}
