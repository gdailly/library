package com.gdailly.library.dto;

import java.time.LocalDate;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.ReadingStatus;

public record ReadingResponse(
        ReadingStatus status,
        @Nullable Integer rating,
        @Nullable String review,
        @Nullable LocalDate startedOn,
        @Nullable LocalDate finishedOn) {
}
