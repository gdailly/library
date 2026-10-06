package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.dto.ReadingRequest;
import com.gdailly.library.dto.ReadingResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Reading;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.ReadingMapperImpl;
import com.gdailly.library.repository.ReadingRepository;
import com.gdailly.library.security.CurrentUser;

class ReadingServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "alice@example.com", 1L, Role.MEMBER);
    /** 23:30 in Paris is already the next day in UTC: dates must follow the users' zone. */
    private static final Clock CLOCK = Clock.fixed(Instant.parse("2026-03-14T22:30:00Z"), ZoneId.of("Europe/Paris"));
    private static final LocalDate TODAY = LocalDate.of(2026, 3, 14);

    private final BookService books = mock(BookService.class);
    private final ReadingRepository readings = mock(ReadingRepository.class);
    private final ReadingService service = new ReadingService(books, readings, CLOCK, new ReadingMapperImpl());

    @BeforeEach
    void setUp() {
        Book book = new Book(1L, 7L);
        ReflectionTestUtils.setField(book, "id", 42L);
        when(books.find(USER, 42L)).thenReturn(book);
        when(readings.findByBookIdAndUserId(42L, 7L)).thenReturn(Optional.empty());
        when(readings.save(any())).thenAnswer(call -> call.getArgument(0));
    }

    @Test
    void startsReadingToday() {
        ReadingResponse response = service.save(USER, 42L, request(ReadingStatus.READING, null, null));
        assertThat(response.startedOn()).isEqualTo(TODAY);
        assertThat(response.finishedOn()).isNull();
    }

    @Test
    void finishesReadingToday() {
        ReadingResponse response = service.save(USER, 42L, request(ReadingStatus.READ, null, null));
        assertThat(response.finishedOn()).isEqualTo(TODAY);
        assertThat(response.startedOn()).isNull();
    }

    @Test
    void keepsGivenDates() {
        LocalDate start = LocalDate.of(2025, 12, 1);
        LocalDate end = LocalDate.of(2026, 1, 15);
        ReadingResponse response = service.save(USER, 42L, request(ReadingStatus.READ, start, end));
        assertThat(response.startedOn()).isEqualTo(start);
        assertThat(response.finishedOn()).isEqualTo(end);
    }

    @Test
    void setsNoDateForOtherStatuses() {
        ReadingResponse toRead = service.save(USER, 42L, request(ReadingStatus.TO_READ, null, null));
        ReadingResponse abandoned = service.save(USER, 42L, request(ReadingStatus.ABANDONED, null, null));
        assertThat(toRead.startedOn()).isNull();
        assertThat(abandoned.finishedOn()).isNull();
    }

    @Test
    void acceptsSameStartAndEnd() {
        ReadingResponse response = service.save(USER, 42L, request(ReadingStatus.READ, TODAY, TODAY));
        assertThat(response.finishedOn()).isEqualTo(TODAY);
    }

    @Test
    void refusesEndBeforeStart() {
        ReadingRequest request = request(ReadingStatus.READ, TODAY, TODAY.minusDays(1));
        assertThatThrownBy(() -> service.save(USER, 42L, request)).isInstanceOf(BadRequestException.class);
        verify(readings, never()).save(any());
    }

    @Test
    void refusesDefaultEndBeforeGivenStart() {
        ReadingRequest request = request(ReadingStatus.READ, TODAY.plusDays(3), null);
        assertThatThrownBy(() -> service.save(USER, 42L, request)).isInstanceOf(BadRequestException.class);
    }

    @Test
    void updatesExistingReadingOfTheUser() {
        Reading existing = new Reading(42L, 7L);
        existing.setStatus(ReadingStatus.READING);
        existing.setRating(2);
        when(readings.findByBookIdAndUserId(42L, 7L)).thenReturn(Optional.of(existing));

        ReadingResponse response = service.save(USER, 42L,
                new ReadingRequest(ReadingStatus.READ, 5, "  Superbe  ", null, null));

        verify(readings).save(existing);
        assertThat(existing.getRating()).isEqualTo(5);
        assertThat(response.review()).isEqualTo("Superbe");
    }

    @Test
    void propagatesUnknownBook() {
        when(books.find(USER, 99L)).thenThrow(new NotFoundException());
        assertThatThrownBy(() -> service.save(USER, 99L, request(ReadingStatus.READ, null, null)))
                .isInstanceOf(NotFoundException.class);
    }

    private static ReadingRequest request(ReadingStatus status, LocalDate startedOn, LocalDate finishedOn) {
        return new ReadingRequest(status, null, null, startedOn, finishedOn);
    }
}
