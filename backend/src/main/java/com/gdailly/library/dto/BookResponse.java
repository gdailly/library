package com.gdailly.library.dto;

import java.time.Instant;
import java.util.List;

import org.jspecify.annotations.Nullable;

/**
 * A shared book; {@code myReading} is the caller's own status, rating and review, null if none yet.
 * {@code cover} is null when the book has no cover (the app then draws one). {@code otherReadings} lists the other
 * members' readings, on a single book only (empty in lists).
 */
public record BookResponse(
        Long id,
        @Nullable String isbn13,
        String title,
        @Nullable String subtitle,
        @Nullable String authors,
        @Nullable String publisher,
        @Nullable Integer year,
        @Nullable Integer pages,
        @Nullable String language,
        @Nullable String summary,
        boolean owned,
        @Nullable Long addedBy,
        @Nullable String addedByName,
        Instant createdAt,
        List<CategoryResponse> categories,
        @Nullable ReadingResponse myReading,
        @Nullable CoverResponse cover,
        List<OtherReadingResponse> otherReadings) {
}
