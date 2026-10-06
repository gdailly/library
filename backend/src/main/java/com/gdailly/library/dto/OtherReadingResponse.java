package com.gdailly.library.dto;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.ReadingStatus;

/** Another member's reading of a shared book, shown on the book page ("Les autres lecteurs"). */
public record OtherReadingResponse(
        Long userId,
        String name,
        ReadingStatus status,
        @Nullable Integer rating,
        @Nullable String review) {
}
