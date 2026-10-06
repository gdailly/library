package com.gdailly.library.client;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import com.gdailly.library.config.LivreProperties;

import tools.jackson.databind.json.JsonMapper;

/**
 * Parses Google Books answers. The payloads follow the documented "volumes" format; recorded answers will join
 * tests/data/isbn once an API key is available (the anonymous quota is exhausted).
 */
class GoogleBooksClientTest {

    private final GoogleBooksClient client =
            new GoogleBooksClient(new LivreProperties(null, null, null, null, null), JsonMapper.builder().build());

    @Test
    void readsFirstVolume() {
        BookMetadata book = client.parse("9782070360024", """
                {"kind": "books#volumes", "totalItems": 2, "items": [
                  {"volumeInfo": {"title": "L'Étranger", "authors": ["Albert Camus"], "publisher": "Gallimard",
                   "publishedDate": "1972", "pageCount": 186, "language": "fr", "description": "Aujourd'hui, maman est morte.",
                   "imageLinks": {"smallThumbnail": "http://books.google.com/books/content?id=a&zoom=5",
                                  "thumbnail": "http://books.google.com/books/content?id=a&zoom=1&edge=curl"}}},
                  {"volumeInfo": {"title": "Autre édition"}}]}
                """).orElseThrow();

        assertThat(book.title()).isEqualTo("L'Étranger");
        assertThat(book.year()).isEqualTo(1972);
        assertThat(book.pages()).isEqualTo(186);
        assertThat(book.language()).isEqualTo("fr");
        assertThat(book.summary()).isEqualTo("Aujourd'hui, maman est morte.");
        assertThat(book.coverUrl()).isEqualTo("https://books.google.com/books/content?id=a&zoom=1");
    }

    @Test
    void joinsAuthorsAndPrefersLargestImage() {
        BookMetadata book = client.parse("9780000000002", """
                {"totalItems": 1, "items": [{"volumeInfo": {"title": "Good Omens", "subtitle": "The Nice and Accurate Prophecies",
                 "authors": ["Terry Pratchett", " ", "Neil Gaiman"], "publishedDate": "2006-11-28", "pageCount": 0,
                 "imageLinks": {"thumbnail": "https://t", "large": "https://l", "medium": "https://m"}}}]}
                """).orElseThrow();

        assertThat(book.subtitle()).isEqualTo("The Nice and Accurate Prophecies");
        assertThat(book.authors()).isEqualTo("Terry Pratchett, Neil Gaiman");
        assertThat(book.year()).isEqualTo(2006);
        assertThat(book.pages()).isNull();
        assertThat(book.coverUrl()).isEqualTo("https://l");
    }

    @Test
    void readsNoMatchAsEmpty() {
        assertThat(client.parse("9780000000002", "{\"kind\": \"books#volumes\", \"totalItems\": 0}")).isEmpty();
        assertThat(client.parse("9780000000002", "{\"items\": [{\"volumeInfo\": {\"title\": \"  \"}}]}")).isEmpty();
        assertThat(client.parse("9780000000002", null)).isEmpty();
    }

    @Test
    void readsVolumeWithoutOptionalFields() {
        BookMetadata book = client.parse("9780000000002", "{\"items\": [{\"volumeInfo\": {\"title\": \"Seul\"}}]}").orElseThrow();
        assertThat(book.authors()).isNull();
        assertThat(book.year()).isNull();
        assertThat(book.coverUrl()).isNull();
    }
}
