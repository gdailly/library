package com.gdailly.library.dto;

import java.util.List;

import org.jspecify.annotations.Nullable;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Body of POST and PUT /api/books; {@code owned} defaults to true, {@code categoryIds} to none. */
public record BookRequest(
        @Size(max = 20) @Nullable String isbn,
        @NotBlank @Size(max = 500) String title,
        @Size(max = 500) @Nullable String subtitle,
        @Size(max = 1000) @Nullable String authors,
        @Size(max = 300) @Nullable String publisher,
        @Min(0) @Max(9999) @Nullable Integer year,
        @Min(1) @Max(100000) @Nullable Integer pages,
        @Size(max = 10) @Nullable String language,
        @Size(max = 20000) @Nullable String summary,
        @Nullable Boolean owned,
        @Size(max = 50) @Nullable List<Long> categoryIds) {
}
