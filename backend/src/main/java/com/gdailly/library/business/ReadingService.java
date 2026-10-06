package com.gdailly.library.business;

import java.time.Clock;
import java.time.LocalDate;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.ReadingRequest;
import com.gdailly.library.dto.ReadingResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Reading;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.mapper.ReadingMapper;
import com.gdailly.library.repository.ReadingRepository;
import com.gdailly.library.security.CurrentUser;

/** Each member keeps their own status, rating and review of a shared book. */
@Service
public class ReadingService {

    private final BookService books;
    private final ReadingRepository readings;
    private final Clock clock;
    private final ReadingMapper readingMapper;

    ReadingService(BookService books, ReadingRepository readings, Clock clock, ReadingMapper readingMapper) {
        this.books = books;
        this.readings = readings;
        this.clock = clock;
        this.readingMapper = readingMapper;
    }

    @Transactional
    public ReadingResponse save(CurrentUser user, Long bookId, ReadingRequest request) {
        Book book = books.find(user, bookId);
        Reading reading = readings.findByBookIdAndUserId(book.getId(), user.userId())
                .orElseGet(() -> new Reading(book.getId(), user.userId()));
        readingMapper.updateEntity(request, reading);

        LocalDate today = LocalDate.now(clock);
        if (reading.getStatus() == ReadingStatus.READING && reading.getStartedOn() == null) {
            reading.setStartedOn(today);
        }
        if (reading.getStatus() == ReadingStatus.READ && reading.getFinishedOn() == null) {
            reading.setFinishedOn(today);
        }
        if (reading.getStartedOn() != null && reading.getFinishedOn() != null
                && reading.getFinishedOn().isBefore(reading.getStartedOn())) {
            throw new BadRequestException("La date de fin précède la date de début.");
        }
        return readingMapper.toResponse(readings.save(reading));
    }
}
