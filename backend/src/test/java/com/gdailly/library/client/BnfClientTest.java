package com.gdailly.library.client;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

import org.junit.jupiter.api.Test;

import com.gdailly.library.config.LivreProperties;

/** Parses answers of the BnF SRU API (tests/data/isbn). */
class BnfClientTest {

    private final BnfClient client = new BnfClient(new LivreProperties(null, null, null, null, null));

    @Test
    void readsOldRecordFoundByIsbn10() throws IOException {
        BookMetadata book = parse("9782070360024").orElseThrow();

        assertThat(book.title()).isEqualTo("L'Étranger");
        assertThat(book.authors()).isEqualTo("Albert Camus");
        assertThat(book.publisher()).isEqualTo("Gallimard");
        assertThat(book.year()).isEqualTo(1971);
        assertThat(book.pages()).isEqualTo(191); // "1 volume 191 p"
        assertThat(book.language()).isEqualTo("fr");
        assertThat(book.coverUrl()).isNull();
    }

    @Test
    void readsRecentRecordAndSkipsSecondaryContributors() throws IOException {
        BookMetadata book = parse("9782072730672").orElseThrow();

        assertThat(book.title()).isEqualTo("Les misérables");
        assertThat(book.authors()).isEqualTo("Victor Hugo");
        assertThat(book.year()).isEqualTo(2017); // "DL 2017"
        assertThat(book.pages()).isEqualTo(1339); // "1 vol. (1339 p.)"
        assertThat(book.language()).isNull();
    }

    @Test
    void readsUnknownIsbnAsEmpty() throws IOException {
        assertThat(parse("9790000000001")).isEmpty();
        assertThat(client.parse("9790000000001", null)).isEmpty();
    }

    @Test
    void removesNonSortingMarkersAndUsesPublicationField214() {
        BookMetadata book = client.parse("9780000000002", """
                <r xmlns:m="info:lc/xmlns/marcxchange-v2"><m:record>
                <m:datafield tag="200"><m:subfield code="a">\u0098Le \u009Cpetit prince</m:subfield>
                  <m:subfield code="e">avec des aquarelles de l'auteur</m:subfield>
                  <m:subfield code="f">Antoine de Saint-Exupéry ; trad. X</m:subfield></m:datafield>
                <m:datafield tag="214"><m:subfield code="c">[Folio]</m:subfield><m:subfield code="d">C 2019</m:subfield></m:datafield>
                <m:datafield tag="330"><m:subfield code="a">Un aviateur...</m:subfield></m:datafield>
                </m:record></r>
                """).orElseThrow();

        assertThat(book.title()).isEqualTo("Le petit prince");
        assertThat(book.subtitle()).isEqualTo("avec des aquarelles de l'auteur");
        assertThat(book.authors()).isEqualTo("Antoine de Saint-Exupéry");
        assertThat(book.publisher()).isEqualTo("Folio");
        assertThat(book.year()).isEqualTo(2019);
        assertThat(book.summary()).isEqualTo("Un aviateur...");
    }

    @Test
    void readsSeriesAndVolumeFromField225() {
        BookMetadata book = client.parse("9782012101357", """
                <r xmlns:m="info:lc/xmlns/marcxchange-v2"><m:record>
                <m:datafield tag="200"><m:subfield code="a">Astérix et les Goths</m:subfield></m:datafield>
                <m:datafield tag="225"><m:subfield code="a">Une aventure d'Astérix</m:subfield><m:subfield code="v">3</m:subfield></m:datafield>
                <m:datafield tag="461"><m:subfield code="t">\u0088Une \u0089aventure d'Astérix</m:subfield><m:subfield code="v">4</m:subfield></m:datafield>
                </m:record></r>
                """).orElseThrow();

        assertThat(book.series()).isEqualTo("Une aventure d'Astérix");
        assertThat(book.seriesNumber()).isEqualTo(3);
    }

    @Test
    void fallsBackToTheSeriesLink461() {
        BookMetadata book = client.parse("9782014001334", """
                <r xmlns:m="info:lc/xmlns/marcxchange-v2"><m:record>
                <m:datafield tag="200"><m:subfield code="a">L'iris blanc</m:subfield></m:datafield>
                <m:datafield tag="461"><m:subfield code="t">\u0088Une \u0089aventure d'Astérix.</m:subfield><m:subfield code="v">T. 40</m:subfield></m:datafield>
                </m:record></r>
                """).orElseThrow();

        assertThat(book.series()).isEqualTo("Une aventure d'Astérix");
        assertThat(book.seriesNumber()).isEqualTo(40);
    }

    @Test
    void searchesIsbn13AndIsbn10() {
        assertThat(BnfClient.query("9782070360024"))
                .isEqualTo("bib.isbn all \"9782070360024\" or bib.isbn all \"2070360024\"");
        assertThat(BnfClient.query("9791032100000")).isEqualTo("bib.isbn all \"9791032100000\"");
    }

    @Test
    void convertsLanguageCodes() {
        assertThat(BnfClient.language("fre")).isEqualTo("fr");
        assertThat(BnfClient.language("eng")).isEqualTo("en");
        assertThat(BnfClient.language("ger")).isEqualTo("de");
        assertThat(BnfClient.language("xyz")).isNull();
    }

    @Test
    void readsPageCounts() {
        assertThat(BnfClient.pages("XII-350 p.")).isEqualTo(350);
        assertThat(BnfClient.pages("1 vol. (non paginé)")).isNull();
        assertThat(BnfClient.pages(null)).isNull();
    }

    private Optional<BookMetadata> parse(String isbn13) throws IOException {
        return client.parse(isbn13, Files.readString(Path.of("..", "tests", "data", "isbn", "bnf-" + isbn13 + ".xml")));
    }
}
