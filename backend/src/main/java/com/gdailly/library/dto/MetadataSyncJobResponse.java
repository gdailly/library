package com.gdailly.library.dto;

import java.time.Instant;

import org.jspecify.annotations.Nullable;

/**
 * Progress of the full resynchronisation: {@code total} books with an ISBN, of which {@code processed} are done
 * ({@code updated} + {@code unchanged} + {@code notFound} + {@code failed}).
 */
public record MetadataSyncJobResponse(
        SyncState state,
        int total,
        int processed,
        int updated,
        int unchanged,
        int notFound,
        int failed,
        @Nullable Instant startedAt,
        @Nullable Instant finishedAt) {
}
