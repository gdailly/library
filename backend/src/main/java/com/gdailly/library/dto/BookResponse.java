package com.gdailly.library.dto;

import java.time.Instant;
import java.util.List;

/**
 * A shared book; {@code myReading} is the caller's own status, rating and review, null if none yet.
 * {@code cover} is null when the book has no cover (the app then draws one).
 */
public record BookResponse(
        Long id,
        String isbn13,
        String title,
        String subtitle,
        String authors,
        String publisher,
        Integer year,
        Integer pages,
        String language,
        String summary,
        boolean owned,
        Long addedBy,
        Instant createdAt,
        List<CategoryResponse> categories,
        ReadingResponse myReading,
        CoverResponse cover) {
}
