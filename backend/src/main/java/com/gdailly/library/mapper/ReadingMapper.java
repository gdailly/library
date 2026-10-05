package com.gdailly.library.mapper;

import com.gdailly.library.dto.ReadingRequest;
import com.gdailly.library.dto.ReadingResponse;
import com.gdailly.library.entity.Reading;

public final class ReadingMapper {

    private ReadingMapper() {
    }

    public static ReadingResponse toResponse(Reading reading) {
        return reading == null ? null : new ReadingResponse(reading.getStatus(), reading.getRating(),
                reading.getReview(), reading.getStartedOn(), reading.getFinishedOn());
    }

    public static void updateEntity(Reading reading, ReadingRequest request) {
        reading.setStatus(request.status());
        reading.setRating(request.rating());
        reading.setReview(BookMapper.blankToNull(request.review()));
        reading.setStartedOn(request.startedOn());
        reading.setFinishedOn(request.finishedOn());
    }
}
