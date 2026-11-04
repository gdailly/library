package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.client.BnfClient.SeriesVolume;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.BookSeriesRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.SeriesRepository;

class SeriesCatalogServiceTest {

    private static final Instant NOW = Instant.parse("2026-11-03T20:00:00Z");
    private static final String GOTHS = "9782012101357";
    private static final String BNF_ANSWER = """
            <r xmlns:m="info:lc/xmlns/marcxchange-v2"><m:record>
            <m:datafield tag="200"><m:subfield code="a">Astérix et les Goths</m:subfield></m:datafield>
            <m:datafield tag="461"><m:subfield code="0">43388366</m:subfield><m:subfield code="v">3</m:subfield></m:datafield>
            </m:record></r>""";

    private final BookRepository books = mock(BookRepository.class);
    private final LibraryBookRepository entries = mock(LibraryBookRepository.class);
    private final SeriesRepository seriesRepository = mock(SeriesRepository.class);
    private final BookSeriesRepository links = mock(BookSeriesRepository.class);
    private final IsbnLookupRepository isbnCache = mock(IsbnLookupRepository.class);
    private final BnfClient bnf = mock(BnfClient.class);
    private final MetadataSources sources = mock(MetadataSources.class);
    private final SyncHistoryService history = mock(SyncHistoryService.class);
    private final SeriesCatalogService service = new SeriesCatalogService(books, entries, seriesRepository, links,
            isbnCache, bnf, sources, history, mock(PlatformTransactionManager.class), Clock.fixed(NOW, ZoneOffset.UTC),
            Duration.ZERO);

    private final Series asterix = series(1L, "Astérix");

    @Test
    void listsTheVolumesOfASeriesAndAddsTheMissingOnesAsBooks() {
        Book goths = book(10L, GOTHS, "Astérix et les Goths");
        List<BookSeries> current = List.of(link(goths, 3));
        when(links.findBySeriesIds(List.of(1L))).thenReturn(current);
        when(entries.findByBookIdIn(List.of(10L))).thenReturn(List.of(new LibraryBook(1L, goths, 7L)));
        IsbnLookup lookup = new IsbnLookup(GOTHS, LookupSource.BNF, "{}", NOW);
        when(isbnCache.findAllById(List.of(GOTHS))).thenReturn(List.of(lookup));
        when(sources.rawPayloads(lookup)).thenReturn(Map.of(LookupSource.BNF, BNF_ANSWER));
        when(bnf.fetchSeriesVolumes("43388366")).thenReturn(List.of(
                new SeriesVolume(3, "Astérix et les Goths", GOTHS, 1999),
                new SeriesVolume(8, "Astérix chez les Bretons", null, 1966)));
        when(books.save(any())).thenAnswer(call -> call.getArgument(0));

        SeriesCatalogService.Refreshed refreshed = service.refresh(1L);

        assertThat(refreshed.status()).isEqualTo(SeriesCatalogStatus.FOUND);
        assertThat(refreshed.listed()).isEqualTo(2);
        assertThat(asterix.getSourceRef()).isEqualTo("43388366");
        assertThat(asterix.getFetchedAt()).isEqualTo(NOW);
        ArgumentCaptor<Book> added = ArgumentCaptor.forClass(Book.class);
        verify(books).save(added.capture());
        assertThat(added.getValue().getTitle()).isEqualTo("Astérix chez les Bretons");
        assertThat(added.getValue().getSeriesLinks()).extracting(BookSeries::getNumber).containsExactly(8);
        assertThat(added.getValue().getSeriesLinks()).extracting(BookSeries::getSeries).containsExactly(asterix);
    }

    @Test
    void linksTheBookOfTheIsbnWhenItAlreadyExists() {
        Book goths = book(10L, GOTHS, "Astérix et les Goths");
        when(links.findBySeriesIds(List.of(1L))).thenReturn(List.of(link(goths, 3)));
        IsbnLookup lookup = new IsbnLookup(GOTHS, LookupSource.BNF, "{}", NOW);
        when(isbnCache.findAllById(List.of(GOTHS))).thenReturn(List.of(lookup));
        when(sources.rawPayloads(lookup)).thenReturn(Map.of(LookupSource.BNF, BNF_ANSWER));
        Book bretons = book(20L, "9782012101388", "Astérix chez les Bretons");
        when(books.findByIsbn13("9782012101388")).thenReturn(Optional.of(bretons));
        when(bnf.fetchSeriesVolumes("43388366")).thenReturn(List.of(
                new SeriesVolume(8, "Astérix chez les Bretons", "9782012101388", 1966)));

        service.refresh(1L);

        verify(books, never()).save(any());
        assertThat(bretons.getSeriesLinks()).extracting(BookSeries::getNumber).containsExactly(8);
    }

    @Test
    void dropsTheBooksOnlyTheBnfKnewWhenItNoLongerListsThemButKeepsHeldOnes() {
        Book goths = book(10L, GOTHS, "Astérix et les Goths");
        Book former = book(11L, null, "Tome disparu");
        Book wished = book(12L, null, "Tome voulu");
        when(links.findBySeriesIds(List.of(1L))).thenReturn(List.of(link(goths, 3), link(former, 5), link(wished, 6)));
        when(entries.findByBookIdIn(any())).thenReturn(List.of(new LibraryBook(1L, goths, 7L),
                new LibraryBook(1L, wished, 7L)));
        IsbnLookup lookup = new IsbnLookup(GOTHS, LookupSource.BNF, "{}", NOW);
        when(isbnCache.findAllById(List.of(GOTHS))).thenReturn(List.of(lookup));
        when(sources.rawPayloads(lookup)).thenReturn(Map.of(LookupSource.BNF, BNF_ANSWER));
        when(bnf.fetchSeriesVolumes("43388366")).thenReturn(List.of(new SeriesVolume(3, "Astérix et les Goths", GOTHS, 1999)));

        service.refresh(1L);

        verify(books).delete(former);
        verify(books, never()).delete(wished);
        verify(books, never()).delete(goths);
        assertThat(wished.getSeriesLinks()).hasSize(1);
    }

    @Test
    void recordsASeriesNoVolumeLinksToTheBnfWithoutCallingIt() {
        when(links.findBySeriesIds(List.of(1L))).thenReturn(List.of(link(book(10L, null, "Carnet"), 1)));

        assertThat(service.refresh(1L).status()).isEqualTo(SeriesCatalogStatus.NO_REFERENCE);
        assertThat(asterix.getStatus()).isEqualTo(SeriesCatalogStatus.NO_REFERENCE);
        verify(bnf, never()).fetchSeriesVolumes(anyString());
    }

    @Test
    void skipsSeriesListedRecently() {
        asterix.listed(SeriesCatalogStatus.FOUND, "1", NOW.minus(Duration.ofDays(29)));
        when(links.findHeld()).thenReturn(List.of(link(book(10L, GOTHS, "Astérix et les Goths"), 3)));

        service.refreshStale();

        verify(bnf, never()).fetchSeriesVolumes(anyString());
        verify(history, never()).start(any(), any(), any(), anyInt());
    }

    @Test
    void tellsWhenASeriesIsDue() {
        assertThat(SeriesCatalogService.isDue(series(2L, "Jamais listée"), NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(listed(SeriesCatalogStatus.FOUND, 31), NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(listed(SeriesCatalogStatus.FOUND, 29), NOW)).isFalse();
        assertThat(SeriesCatalogService.isDue(listed(SeriesCatalogStatus.NOT_FOUND, 8), NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(listed(SeriesCatalogStatus.NOT_FOUND, 6), NOW)).isFalse();
    }

    @Test
    void keepsOnePrintingPerVolumePreferringAnIsbnThenTheLatest() {
        List<SeriesVolume> chosen = SeriesCatalogService.choose(List.of(
                new SeriesVolume(2, "La serpe d'or", null, 2010),
                new SeriesVolume(2, "La serpe d'or", "9782012101340", 1999),
                new SeriesVolume(2, "La serpe d'or", "9782012101341", 2004),
                new SeriesVolume(null, "Hors série", null, 2004),
                new SeriesVolume(1, "Astérix le Gaulois", null, null)));

        assertThat(chosen).extracting(SeriesVolume::number).containsExactly(1, 2);
        assertThat(chosen.get(1).isbn13()).isEqualTo("9782012101341");
    }

    @Test
    void describesEachVolumeAgainstTheLastListingAndTheLibrary() {
        var refreshed = new SeriesCatalogService.Refreshed(SeriesCatalogStatus.FOUND, 2,
                List.of(new SeriesVolume(1, "Astérix le Gaulois", "9782012101333", 1961),
                        new SeriesVolume(3, "Astérix et les Goths", null, null)),
                List.of(new SeriesVolume(1, "Astérix le Gaulois", "9782012101333", 1961),
                        new SeriesVolume(2, "La Serpe d'or", null, 1962)),
                Map.of(1, true, 3, false));

        List<SyncHistoryService.Child> lines = SeriesCatalogService.volumeLines(refreshed);

        assertThat(lines).containsExactly(
                new SyncHistoryService.Child("Tome 1 · Astérix le Gaulois", SyncItemOutcome.UNCHANGED,
                        "ISBN 9782012101333 · 1961 · possédé"),
                new SyncHistoryService.Child("Tome 2 · La Serpe d'or", SyncItemOutcome.REMOVED,
                        "1962 · manquant dans la bibliothèque"),
                new SyncHistoryService.Child("Tome 3 · Astérix et les Goths", SyncItemOutcome.ADDED, "dans les envies"));
    }

    private Series series(Long id, String name) {
        Series series = new Series(name, name.toLowerCase());
        ReflectionTestUtils.setField(series, "id", id);
        when(seriesRepository.findById(id)).thenReturn(Optional.of(series));
        return series;
    }

    private Series listed(SeriesCatalogStatus status, int daysAgo) {
        Series series = new Series("Série", "serie");
        series.listed(status, "1", NOW.minus(Duration.ofDays(daysAgo)));
        return series;
    }

    private BookSeries link(Book book, Integer number) {
        BookSeries link = new BookSeries(book, asterix, number);
        book.getSeriesLinks().add(link);
        return link;
    }

    private static Book book(Long id, String isbn13, String title) {
        Book book = new Book();
        ReflectionTestUtils.setField(book, "id", id);
        book.setIsbn13(isbn13);
        book.setTitle(title);
        return book;
    }

}
