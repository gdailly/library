package com.gdailly.library.dto;

import java.time.Instant;
import java.util.List;

import org.jspecify.annotations.Nullable;

/**
 * A series volume by volume, with the books that have no volume number apart. {@code catalogFetchedAt} is when the BnF
 * listing of its volumes was last read, null when it has not been yet.
 */
public record SeriesDetailResponse(
        String name,
        List<SeriesVolumeResponse> volumes,
        List<BookResponse> unnumbered,
        @Nullable Instant catalogFetchedAt) {
}
