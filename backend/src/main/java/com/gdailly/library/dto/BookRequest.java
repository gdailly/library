package com.gdailly.library.dto;

import java.util.List;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Body of POST and PUT /api/books; {@code owned} defaults to true, {@code categoryIds} to none. */
public record BookRequest(
        @Size(max = 20) String isbn,
        @NotBlank @Size(max = 500) String title,
        @Size(max = 500) String subtitle,
        @Size(max = 1000) String authors,
        @Size(max = 300) String publisher,
        @Min(0) @Max(9999) Integer year,
        @Min(1) @Max(100000) Integer pages,
        @Size(max = 10) String language,
        @Size(max = 20000) String summary,
        Boolean owned,
        @Size(max = 50) List<Long> categoryIds) {
}
