package com.gdailly.library.client;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;

import com.gdailly.library.config.LivreProperties;

import tools.jackson.databind.json.JsonMapper;

/** Parses answers recorded from the real Open Library API (tests/data/isbn). */
class OpenLibraryClientTest {

    private final OpenLibraryClient client =
            new OpenLibraryClient(new LivreProperties(null, null, null, null, null), JsonMapper.builder().build());

    @Test
    void readsLePetitPrince() throws IOException {
        BookMetadata book = parse("9782070612758").orElseThrow();

        assertThat(book.title()).isEqualTo("Le Petit Prince");
        assertThat(book.authors()).isEqualTo("Antoine de Saint-Exupéry");
        assertThat(book.publisher()).isEqualTo("Editions Gallimard");
        assertThat(book.year()).isEqualTo(2007); // "March 2007"
        assertThat(book.pages()).isEqualTo(120);
        assertThat(book.coverUrl()).isEqualTo("https://covers.openlibrary.org/b/id/2137711-L.jpg");
    }

    @Test
    void readsDayMonthYearDateAndMissingCover() throws IOException {
        BookMetadata book = parse("9782070360024").orElseThrow();

        assertThat(book.title()).isEqualTo("L’étranger");
        assertThat(book.authors()).isEqualTo("Albert Camus");
        assertThat(book.year()).isEqualTo(1972); // "07-01-1972"
        assertThat(book.coverUrl()).isNull();
    }

    @Test
    void removesCatalogueBracketsAroundPublisher() throws IOException {
        BookMetadata book = parse("9782253004226").orElseThrow();

        assertThat(book.title()).isEqualTo("Germinal");
        assertThat(book.authors()).isEqualTo("Émile Zola");
        assertThat(book.publisher()).isEqualTo("Librairie Générale Française");
        assertThat(book.year()).isEqualTo(1983);
        assertThat(book.pages()).isEqualTo(503);
    }

    @Test
    void readsEnglishEdition() throws IOException {
        BookMetadata book = parse("9780547928227").orElseThrow();

        assertThat(book.title()).isEqualTo("The Hobbit");
        assertThat(book.authors()).isEqualTo("J.R.R. Tolkien");
        assertThat(book.publisher()).isEqualTo("Mariner Books");
        assertThat(book.year()).isEqualTo(2012);
    }

    @Test
    void readsUnknownIsbnAsEmpty() throws IOException {
        assertThat(parse("9790000000001")).isEmpty();
        assertThat(client.parse("9790000000001", null)).isEmpty();
        assertThat(client.parse("9790000000001", " ")).isEmpty();
    }

    @Test
    void ignoresAnswerForAnotherIsbn() throws IOException {
        assertThat(client.parse("9780547928227", fixture("9782070612758"))).isEmpty();
    }

    @Test
    void skipsBlankAuthorNames() {
        BookMetadata book = client.parse("9780000000002", """
                {"ISBN:9780000000002": {"title": "Recueil", "authors": [{"name": "Anne"}, {"name": " "}, {"url": "x"}, {"name": "Paul"}]}}
                """).orElseThrow();
        assertThat(book.authors()).isEqualTo("Anne, Paul");

        BookMetadata anonymous = client.parse("9780000000002",
                "{\"ISBN:9780000000002\": {\"title\": \"Anonyme\", \"authors\": [{\"name\": \"\"}]}}").orElseThrow();
        assertThat(anonymous.authors()).isNull();
    }

    @Test
    void keepsPublisherWithoutBrackets() {
        assertThat(OpenLibraryClient.publisher("Gallimard")).isEqualTo("Gallimard");
        assertThat(OpenLibraryClient.publisher("[ ]")).isNull();
        assertThat(OpenLibraryClient.publisher(null)).isNull();
    }

    private java.util.Optional<BookMetadata> parse(String isbn13) throws IOException {
        return client.parse(isbn13, fixture(isbn13));
    }

    private static String fixture(String isbn13) throws IOException {
        return Files.readString(Path.of("..", "tests", "data", "isbn", "open-library-" + isbn13 + ".json"));
    }
}
