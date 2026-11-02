package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Role;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.security.CurrentUser;

class SeriesServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "a@example.com", 1L, Role.MEMBER);

    private final BookRepository books = mock(BookRepository.class);
    private final CoverService covers = mock(CoverService.class);
    private final SeriesService service = new SeriesService(books, covers);

    @Test
    void listsOwnedWishedAndMissingVolumes() {
        when(books.findByLibraryIdAndSeriesIsNotNull(1L)).thenReturn(List.of(
                book(1, "Une aventure d'Astérix", 3, true, "c3"),
                book(2, "Une aventure d’Asterix ", 1, true, "c1"),
                book(3, "Une aventure d'Astérix", 5, false, null),
                book(4, "Une aventure d'Astérix", null, true, null),
                book(5, "Blake et Mortimer", 2, true, null)));
        CoverResponse cover = new CoverResponse("thumb-1", "medium-1");
        when(covers.urls(any())).thenAnswer(call -> "c1".equals(((Book) call.getArgument(0)).getCoverKey()) ? cover : null);

        List<SeriesResponse> series = service.list(USER, null);

        assertThat(series).extracting(SeriesResponse::name).containsExactly("Blake et Mortimer", "Une aventure d'Astérix");
        SeriesResponse asterix = series.get(1);
        assertThat(asterix.books()).isEqualTo(4);
        assertThat(asterix.owned()).isEqualTo(3);
        assertThat(asterix.ownedNumbers()).containsExactly(1, 3);
        assertThat(asterix.wishedNumbers()).containsExactly(5);
        assertThat(asterix.missingNumbers()).containsExactly(2, 4, 5);
        assertThat(asterix.lastNumber()).isEqualTo(5);
        assertThat(asterix.unnumbered()).isEqualTo(1);
        assertThat(asterix.cover()).isEqualTo(cover); // volume 1, the first with a cover
        assertThat(series.get(0).missingNumbers()).containsExactly(1);
    }

    @Test
    void filtersByNameIgnoringCaseAndAccents() {
        when(books.findByLibraryIdAndSeriesIsNotNull(1L)).thenReturn(List.of(
                book(1, "Une aventure d'Astérix", 1, true, null), book(2, "Tintin", 1, true, null)));

        assertThat(service.list(USER, "ASTERIX")).extracting(SeriesResponse::name).containsExactly("Une aventure d'Astérix");
        assertThat(service.list(USER, " ")).hasSize(2);
    }

    @Test
    void ignoresAbsurdVolumeNumbersWhenListingGaps() {
        when(books.findByLibraryIdAndSeriesIsNotNull(1L)).thenReturn(List.of(book(1, "Saga", 9000, true, null)));

        SeriesResponse saga = service.list(USER, null).getFirst();

        assertThat(saga.lastNumber()).isEqualTo(9000);
        assertThat(saga.missingNumbers()).hasSize(SeriesService.MAX_LISTED_NUMBER);
    }

    private static Book book(long id, String series, Integer number, boolean owned, String coverKey) {
        Book book = new Book(1L, 7L);
        ReflectionTestUtils.setField(book, "id", id);
        book.setTitle("Livre " + id);
        book.setSeries(series);
        book.setSeriesNumber(number);
        book.setOwned(owned);
        book.setCoverKey(coverKey);
        return book;
    }
}
