package com.gdailly.library.dto;

import java.time.Instant;

import org.jspecify.annotations.Nullable;

/**
 * Progress of the forced listing of every series: {@code total} series, of which {@code processed} are done
 * ({@code found} + {@code notFound} + {@code failed}); {@code notFound} also counts the series no BnF record links to.
 */
public record SeriesSyncJobResponse(
        SyncState state,
        int total,
        int processed,
        int found,
        int notFound,
        int failed,
        @Nullable Instant startedAt,
        @Nullable Instant finishedAt) {
}
