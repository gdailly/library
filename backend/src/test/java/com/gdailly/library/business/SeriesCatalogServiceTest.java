package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
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
import org.springframework.transaction.PlatformTransactionManager;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.SeriesCatalog;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.entity.SeriesVolume;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.repository.SeriesCatalogRepository;
import com.gdailly.library.repository.SeriesVolumeRepository;

class SeriesCatalogServiceTest {

    private static final Instant NOW = Instant.parse("2026-11-03T20:00:00Z");
    private static final String GOTHS = "9782012101357";
    private static final String BNF_ANSWER = """
            <r xmlns:m="info:lc/xmlns/marcxchange-v2"><m:record>
            <m:datafield tag="200"><m:subfield code="a">Astérix et les Goths</m:subfield></m:datafield>
            <m:datafield tag="461"><m:subfield code="0">43388366</m:subfield><m:subfield code="v">3</m:subfield></m:datafield>
            </m:record></r>""";

    private final BookRepository books = mock(BookRepository.class);
    private final IsbnLookupRepository isbnCache = mock(IsbnLookupRepository.class);
    private final SeriesCatalogRepository catalogs = mock(SeriesCatalogRepository.class);
    private final SeriesVolumeRepository volumes = mock(SeriesVolumeRepository.class);
    private final BnfClient bnf = mock(BnfClient.class);
    private final MetadataSources sources = mock(MetadataSources.class);
    private final SyncHistoryService history = mock(SyncHistoryService.class);
    private final SeriesCatalogService service = new SeriesCatalogService(books, isbnCache, catalogs, volumes, bnf,
            sources, history, mock(PlatformTransactionManager.class), Clock.fixed(NOW, ZoneOffset.UTC), Duration.ZERO);

    @Test
    void listsTheVolumesOfANewSeriesFromTheBnfRecordOfAVolume() {
        Book goths = book(GOTHS, "Une aventure d'Astérix");
        when(books.findAllWithSeries()).thenReturn(List.of(goths));
        IsbnLookup lookup = new IsbnLookup(GOTHS, LookupSource.BNF, "{}", NOW);
        when(isbnCache.findAllById(List.of(GOTHS))).thenReturn(List.of(lookup));
        when(sources.rawPayloads(lookup)).thenReturn(Map.of(LookupSource.BNF, BNF_ANSWER));
        when(bnf.fetchSeriesVolumes("43388366")).thenReturn(List.of(
                new BnfClient.SeriesVolume(3, "Astérix et les Goths", "9782012101357", 1999),
                new BnfClient.SeriesVolume(8, "Astérix chez les Bretons", null, 1966)));
        when(catalogs.findById(any())).thenReturn(Optional.empty());

        service.refreshStale();

        ArgumentCaptor<SeriesCatalog> catalog = ArgumentCaptor.forClass(SeriesCatalog.class);
        verify(catalogs).save(catalog.capture());
        assertThat(catalog.getValue().getSeriesKey()).isEqualTo("une aventure d'asterix");
        assertThat(catalog.getValue().getStatus()).isEqualTo(SeriesCatalogStatus.FOUND);
        assertThat(catalog.getValue().getSourceRef()).isEqualTo("43388366");
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<SeriesVolume>> saved = ArgumentCaptor.forClass(List.class);
        verify(volumes).saveAll(saved.capture());
        assertThat(saved.getValue()).extracting(SeriesVolume::getNumber).containsExactly(3, 8);
    }

    @Test
    void recordsASeriesNoVolumeLinksToTheBnfWithoutCallingIt() {
        when(books.findAllWithSeries()).thenReturn(List.of(book(null, "Mes carnets")));
        when(catalogs.findById(any())).thenReturn(Optional.empty());

        service.refreshStale();

        ArgumentCaptor<SeriesCatalog> catalog = ArgumentCaptor.forClass(SeriesCatalog.class);
        verify(catalogs).save(catalog.capture());
        assertThat(catalog.getValue().getStatus()).isEqualTo(SeriesCatalogStatus.NO_REFERENCE);
        verify(bnf, never()).fetchSeriesVolumes(any());
    }

    @Test
    void skipsSeriesListedRecently() {
        when(books.findAllWithSeries()).thenReturn(List.of(book(GOTHS, "Tintin")));
        when(catalogs.findAllById(any())).thenReturn(List.of(
                new SeriesCatalog("tintin", SeriesCatalogStatus.FOUND, "1", NOW.minus(Duration.ofDays(29)))));

        service.refreshStale();

        verify(bnf, never()).fetchSeriesVolumes(any());
        verify(catalogs, never()).save(any());
    }

    @Test
    void tellsWhenASeriesIsDue() {
        assertThat(SeriesCatalogService.isDue(null, NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(
                new SeriesCatalog("a", SeriesCatalogStatus.FOUND, "1", NOW.minus(Duration.ofDays(31))), NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(
                new SeriesCatalog("a", SeriesCatalogStatus.NOT_FOUND, "1", NOW.minus(Duration.ofDays(8))), NOW)).isTrue();
        assertThat(SeriesCatalogService.isDue(
                new SeriesCatalog("a", SeriesCatalogStatus.NOT_FOUND, "1", NOW.minus(Duration.ofDays(6))), NOW)).isFalse();
    }

    @Test
    void keepsOnePrintingPerVolumePreferringAnIsbnThenTheLatest() {
        List<SeriesVolume> chosen = SeriesCatalogService.choose("k", List.of(
                new BnfClient.SeriesVolume(2, "La serpe d'or", null, 2010),
                new BnfClient.SeriesVolume(2, "La serpe d'or", "9782012101340", 1999),
                new BnfClient.SeriesVolume(2, "La serpe d'or", "9782012101341", 2004),
                new BnfClient.SeriesVolume(null, "Hors série", null, 2004),
                new BnfClient.SeriesVolume(1, "Astérix le Gaulois", null, null)));

        assertThat(chosen).extracting(SeriesVolume::getNumber).containsExactly(1, 2);
        assertThat(chosen.get(1).getIsbn13()).isEqualTo("9782012101341");
    }

    @Test
    void describesEachVolumeAgainstTheLastListingAndTheLibrary() {
        Book owned = book("9782012101333", "Astérix");
        owned.setSeriesNumber(1);
        Book wished = book(null, "Astérix");
        wished.setSeriesNumber(3);
        wished.setOwned(false);
        var refreshed = new SeriesCatalogService.Refreshed(SeriesCatalogStatus.FOUND,
                List.of(new SeriesVolume("asterix", 1, "Astérix le Gaulois", "9782012101333", 1961),
                        new SeriesVolume("asterix", 3, "Astérix et les Goths", null, null)),
                List.of(new SeriesVolume("asterix", 1, "Astérix le Gaulois", "9782012101333", 1961),
                        new SeriesVolume("asterix", 2, "La Serpe d'or", null, 1962)));

        List<SyncHistoryService.Child> lines = SeriesCatalogService.volumeLines(List.of(owned, wished), refreshed);

        assertThat(lines).containsExactly(
                new SyncHistoryService.Child("Tome 1 · Astérix le Gaulois", SyncItemOutcome.UNCHANGED,
                        "ISBN 9782012101333 · 1961 · possédé"),
                new SyncHistoryService.Child("Tome 2 · La Serpe d'or", SyncItemOutcome.REMOVED,
                        "1962 · manquant dans la bibliothèque"),
                new SyncHistoryService.Child("Tome 3 · Astérix et les Goths", SyncItemOutcome.ADDED, "dans les envies"));
    }

    private static Book book(String isbn13, String series) {
        Book book = new Book(1L, 7L);
        book.setTitle("Livre");
        book.setIsbn13(isbn13);
        book.setSeries(series);
        return book;
    }
}
