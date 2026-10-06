package com.gdailly.library.dto;

import org.jspecify.annotations.Nullable;

/** {@code bookCount} is only given by GET /api/categories. */
public record CategoryResponse(Long id, String name, String color, @Nullable Long bookCount) {
}
