package com.gdailly.library.dto;

import java.time.Instant;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.SyncItemOutcome;

/**
 * What a synchronisation did with one book or series ({@code label}); {@code detail} explains it in French.
 * {@code childCount}: how many volumes are listed under a series (see the children route).
 */
public record SyncRunItemResponse(
        long id,
        String label,
        SyncItemOutcome outcome,
        @Nullable String detail,
        int childCount,
        Instant createdAt) {
}
