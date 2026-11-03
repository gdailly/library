package com.gdailly.library.dto;

import java.util.List;

import org.jspecify.annotations.Nullable;

/**
 * One volume of a series: {@code books} holds the library's books of this volume (owned or wished), empty when it has
 * none. {@code title}, {@code isbn13} and {@code year} come from the BnF listing when known. {@code coverUrl} is an
 * external image of a volume the library does not hold (it may not exist).
 */
public record SeriesVolumeResponse(
        int number,
        @Nullable String title,
        @Nullable String isbn13,
        @Nullable Integer year,
        @Nullable String coverUrl,
        List<BookResponse> books) {
}
