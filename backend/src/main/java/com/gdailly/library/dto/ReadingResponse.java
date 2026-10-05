package com.gdailly.library.dto;

import java.time.LocalDate;

import com.gdailly.library.entity.ReadingStatus;

public record ReadingResponse(
        ReadingStatus status,
        Integer rating,
        String review,
        LocalDate startedOn,
        LocalDate finishedOn) {
}
