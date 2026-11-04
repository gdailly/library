package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.Role;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.repository.BookSeriesRepository;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.SeriesRepository;
import com.gdailly.library.security.CurrentUser;

class SeriesServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "a@example.com", 1L, Role.MEMBER);

    private final LibraryBookRepository entries = mock(LibraryBookRepository.class);
    private final BookSeriesRepository links = mock(BookSeriesRepository.class);
    private final CoverService covers = mock(CoverService.class);
    private final SeriesService service = new SeriesService(entries, links, mock(SeriesRepository.class), covers,
            mock(BookService.class));

    private final List<BookSeries> all = new ArrayList<>();
    private final List<LibraryBook> mine = new ArrayList<>();

    @Test
    void listsOwnedWishedAndMissingVolumes() {
        Series asterix = series(1, "Une aventure d'Astérix");
        Series blake = series(2, "Blake et Mortimer");
        held(book(1, "c3"), asterix, 3, true);
        held(book(2, "c1"), asterix, 1, true);
        held(book(3, null), asterix, 5, false);
        held(book(4, null), asterix, null, true);
        held(book(5, null), blake, 2, true);
        CoverResponse cover = new CoverResponse("thumb-1", "medium-1");
        when(covers.urls(any())).thenAnswer(call -> "c1".equals(((Book) call.getArgument(0)).getCoverKey()) ? cover : null);
        mockRepositories();

        List<SeriesResponse> series = service.list(USER, null);

        assertThat(series).extracting(SeriesResponse::name).containsExactly("Blake et Mortimer", "Une aventure d'Astérix");
        SeriesResponse found = series.get(1);
        assertThat(found.books()).isEqualTo(4);
        assertThat(found.owned()).isEqualTo(3);
        assertThat(found.ownedNumbers()).containsExactly(1, 3);
        assertThat(found.wishedNumbers()).containsExactly(5);
        assertThat(found.missingNumbers()).containsExactly(2, 4, 5);
        assertThat(found.lastNumber()).isEqualTo(5);
        assertThat(found.unnumbered()).isEqualTo(1);
        assertThat(found.catalogVolumes()).isNull();
        assertThat(found.cover()).isEqualTo(cover); // volume 1, the first with a cover
        assertThat(series.get(0).missingNumbers()).containsExactly(1);
    }

    @Test
    void filtersByNameIgnoringCaseAndAccents() {
        held(book(1, null), series(1, "Une aventure d'Astérix"), 1, true);
        held(book(2, null), series(2, "Tintin"), 1, true);
        mockRepositories();

        assertThat(service.list(USER, "ASTERIX")).extracting(SeriesResponse::name).containsExactly("Une aventure d'Astérix");
        assertThat(service.list(USER, " ")).hasSize(2);
    }

    @Test
    void ignoresAbsurdVolumeNumbersWhenListingGaps() {
        held(book(1, null), series(1, "Saga"), 9000, true);
        mockRepositories();

        SeriesResponse saga = service.list(USER, null).getFirst();

        assertThat(saga.lastNumber()).isEqualTo(9000);
        assertThat(saga.missingNumbers()).hasSize(SeriesService.MAX_LISTED_NUMBER);
    }

    @Test
    void countsTheVolumesTheLibraryDoesNotHoldAsMissing() {
        Series tintin = series(1, "Tintin");
        tintin.listed(SeriesCatalogStatus.FOUND, "1", Instant.parse("2026-11-01T00:00:00Z"));
        held(book(1, null), tintin, 2, true);
        all.add(new BookSeries(book(10, null), tintin, 1));
        all.add(new BookSeries(book(11, null), tintin, 4));
        mockRepositories();

        SeriesResponse found = service.list(USER, null).getFirst();

        assertThat(found.books()).isEqualTo(1);
        assertThat(found.lastNumber()).isEqualTo(4);
        assertThat(found.catalogVolumes()).isEqualTo(3);
        assertThat(found.missingNumbers()).containsExactly(1, 3, 4);
    }

    private void mockRepositories() {
        when(links.findHeldBy(1L)).thenReturn(all.stream()
                .filter(link -> mine.stream().anyMatch(entry -> entry.getBook() == link.getBook())).toList());
        when(links.findBySeriesIds(anyCollection())).thenReturn(all);
        when(entries.findByLibraryIdAndBookIdIn(eq(1L), anyCollection())).thenReturn(mine);
    }

    private void held(Book book, Series series, Integer number, boolean owned) {
        all.add(new BookSeries(book, series, number));
        LibraryBook entry = new LibraryBook(1L, book, 7L);
        entry.setOwned(owned);
        mine.add(entry);
    }

    private static Series series(long id, String name) {
        Series series = new Series(name, SeriesService.key(name));
        ReflectionTestUtils.setField(series, "id", id);
        return series;
    }

    private static Book book(long id, String coverKey) {
        Book book = new Book();
        ReflectionTestUtils.setField(book, "id", id);
        book.setTitle("Livre " + id);
        book.setCoverKey(coverKey);
        return book;
    }
}
