package com.gdailly.library.dto;

import java.time.LocalDate;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.ReadingStatus;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Body of PUT /api/books/{id}/reading. When omitted, {@code startedOn} defaults to today for READING
 * and {@code finishedOn} to today for READ.
 */
public record ReadingRequest(
        @NotNull ReadingStatus status,
        @Min(1) @Max(5) @Nullable Integer rating,
        @Size(max = 20000) @Nullable String review,
        @Nullable LocalDate startedOn,
        @Nullable LocalDate finishedOn) {
}
