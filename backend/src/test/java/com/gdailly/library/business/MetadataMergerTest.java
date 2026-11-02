package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;

import org.junit.jupiter.api.Test;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.entity.LookupSource;

class MetadataMergerTest {

    private static final BookMetadata OPEN_LIBRARY = new BookMetadata("L’étranger", null, "Albert Camus",
            "Editions Gallimard", 1972, 186, null, null, "https://covers.openlibrary.org/1-L.jpg");
    private static final BookMetadata GOOGLE = new BookMetadata("L'Étranger", "roman", "Albert Camus", "Folio", 1942,
            159, "fr", "Aujourd'hui, maman est morte.", "https://books.google.com/1");
    private static final BookMetadata BNF = new BookMetadata("L'Étranger", null, "Albert Camus", "Gallimard", 1971,
            191, "fr", null, null);

    @Test
    void takesEachFieldFromItsPreferredSource() {
        MetadataMerger.Merged merged = MetadataMerger.merge(Map.of(
                LookupSource.OPEN_LIBRARY, OPEN_LIBRARY, LookupSource.GOOGLE_BOOKS, GOOGLE, LookupSource.BNF, BNF))
                .orElseThrow();

        assertThat(merged.source()).isEqualTo(LookupSource.BNF);
        BookMetadata book = merged.metadata();
        assertThat(book.title()).isEqualTo("L'Étranger");
        assertThat(book.subtitle()).isEqualTo("roman"); // only Google Books has one
        assertThat(book.publisher()).isEqualTo("Gallimard");
        assertThat(book.year()).isEqualTo(1971);
        assertThat(book.pages()).isEqualTo(186); // Open Library first
        assertThat(book.language()).isEqualTo("fr");
        assertThat(book.summary()).isEqualTo("Aujourd'hui, maman est morte.");
        assertThat(book.coverUrl()).isEqualTo("https://books.google.com/1");
        assertThat(merged.coverUrls()).containsExactly("https://books.google.com/1", "https://covers.openlibrary.org/1-L.jpg");
    }

    @Test
    void usesTheOnlySourceThatAnswered() {
        MetadataMerger.Merged merged = MetadataMerger.merge(Map.of(LookupSource.GOOGLE_BOOKS, GOOGLE)).orElseThrow();

        assertThat(merged.source()).isEqualTo(LookupSource.GOOGLE_BOOKS);
        assertThat(merged.metadata()).isEqualTo(GOOGLE);
    }

    @Test
    void isEmptyWithoutAnswers() {
        assertThat(MetadataMerger.merge(Map.of())).isEmpty();
    }

    @Test
    void takesSeriesAndVolumeTogetherFromTheFirstSourceNamingIt() {
        BookMetadata openLibrary = new BookMetadata("Astérix et les Goths", null, null, null, null, null, null, null,
                null, "Astérix", null);
        BookMetadata bnf = new BookMetadata("Astérix et les Goths", null, null, null, null, null, null, null, null,
                "Une aventure d'Astérix", 3);

        BookMetadata both = MetadataMerger.merge(Map.of(LookupSource.OPEN_LIBRARY, openLibrary, LookupSource.BNF, bnf))
                .orElseThrow().metadata();
        assertThat(both.series()).isEqualTo("Une aventure d'Astérix");
        assertThat(both.seriesNumber()).isEqualTo(3);

        BookMetadata onlyOpenLibrary = MetadataMerger.merge(Map.of(LookupSource.OPEN_LIBRARY, openLibrary,
                LookupSource.BNF, BNF)).orElseThrow().metadata();
        assertThat(onlyOpenLibrary.series()).isEqualTo("Astérix");
        assertThat(onlyOpenLibrary.seriesNumber()).isNull();
    }
}
