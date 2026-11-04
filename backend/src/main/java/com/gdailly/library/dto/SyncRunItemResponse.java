package com.gdailly.library.dto;

import java.time.Instant;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.SyncItemOutcome;

/** What a synchronisation did with one book or series ({@code label}); {@code detail} explains it in French. */
public record SyncRunItemResponse(
        long id,
        String label,
        SyncItemOutcome outcome,
        @Nullable String detail,
        Instant createdAt) {
}
