package com.gdailly.library.repository;

import com.gdailly.library.entity.ReadingStatus;

/**
 * Criteria of the book list; every null field is ignored.
 *
 * @param pattern    lower-case LIKE pattern matched against title, subtitle and authors
 * @param isbn13     exact ISBN, matched as an alternative to {@code pattern}
 * @param userId     whose reading {@code status} and {@code minRating} refer to
 */
public record BookFilter(
        Long libraryId,
        String pattern,
        String isbn13,
        Boolean owned,
        Long categoryId,
        Long userId,
        ReadingStatus status,
        Integer minRating) {
}
