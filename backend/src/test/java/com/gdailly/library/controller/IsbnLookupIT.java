package com.gdailly.library.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.gdailly.library.IntegrationTest;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.repository.IsbnLookupRepository;

class IsbnLookupIT extends IntegrationTest {

    @Autowired
    private IsbnLookupRepository cache;

    @AfterEach
    void restoreGoogleBooks() {
        METADATA.googleBooksDown(false);
    }

    @Test
    void readsOpenLibraryThenServesFromCache() throws Exception {
        String isbn = "9780000000002";
        METADATA.openLibraryKnows(isbn, """
                {"title": "Vingt mille lieues sous les mers", "authors": [{"name": "Jules Verne"}, {"name": "Alphonse de Neuville"}],
                 "publishers": [{"name": "Hetzel"}], "publish_date": "March 1870", "number_of_pages": 432,
                 "cover": {"large": "https://covers.openlibrary.org/b/id/1-L.jpg"}}
                """);

        mvc.perform(get("/api/lookup/isbn/{isbn}", "978-0-00-000000-2").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").value("OPEN_LIBRARY"))
                .andExpect(jsonPath("$.isbn13").value(isbn))
                .andExpect(jsonPath("$.authors").value("Jules Verne, Alphonse de Neuville"))
                .andExpect(jsonPath("$.year").value(1870))
                .andExpect(jsonPath("$.pages").value(432))
                .andExpect(jsonPath("$.coverUrl").value("https://covers.openlibrary.org/b/id/1-L.jpg"));
        int calls = METADATA.calls(isbn);

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.publisher").value("Hetzel"));
        assertThat(METADATA.calls(isbn)).isEqualTo(calls);
    }

    @Test
    void fallsBackToGoogleBooks() throws Exception {
        String isbn = "9780000000019";
        METADATA.googleBooksKnows(isbn, """
                {"title": "L'Étranger", "authors": ["Albert Camus"], "publisher": "Gallimard", "publishedDate": "1942-05-19",
                 "pageCount": 159, "language": "fr", "description": "Aujourd'hui, maman est morte.",
                 "imageLinks": {"thumbnail": "http://books.google.com/books/content?id=x&zoom=1&edge=curl"}}
                """);

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").value("GOOGLE_BOOKS"))
                .andExpect(jsonPath("$.year").value(1942))
                .andExpect(jsonPath("$.language").value("fr"))
                .andExpect(jsonPath("$.summary").value("Aujourd'hui, maman est morte."))
                .andExpect(jsonPath("$.coverUrl").value("https://books.google.com/books/content?id=x&zoom=1"));
        assertThat(cache.findById(isbn)).get().extracting(IsbnLookup::getSource).isEqualTo(LookupSource.GOOGLE_BOOKS);
    }

    @Test
    void remembersUnknownIsbn() throws Exception {
        String isbn = "9780000000026";
        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner())).andExpect(status().isNotFound());
        int calls = METADATA.calls(isbn);
        assertThat(calls).isEqualTo(2);

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner())).andExpect(status().isNotFound());
        assertThat(METADATA.calls(isbn)).isEqualTo(calls);
    }

    @Test
    void doesNotCacheNotFoundWhenASourceIsDown() throws Exception {
        String isbn = "9780000000033";
        METADATA.googleBooksDown(true);
        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner())).andExpect(status().isServiceUnavailable());
        assertThat(cache.findById(isbn)).isEmpty();

        METADATA.googleBooksDown(false);
        METADATA.googleBooksKnows(isbn, "{\"title\": \"La Peste\"}");
        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("La Peste"));
    }

    @Test
    void returnsBookAlreadyInLibraryWithoutCallingApis() throws Exception {
        String isbn = "9780000000040";
        long id = createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Déjà là\"}");

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").value("LIBRARY"))
                .andExpect(jsonPath("$.existingBookId").value(id));
        assertThat(METADATA.calls(isbn)).isZero();
    }

    @Test
    void refreshesExpiredNotFound() throws Exception {
        String isbn = "9780000000057";
        cache.save(new IsbnLookup(isbn, LookupSource.NOT_FOUND, null, Instant.now().minus(Duration.ofDays(8))));
        METADATA.openLibraryKnows(isbn, "{\"title\": \"Enfin trouvé\"}");

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").value("OPEN_LIBRARY"));
    }

    @Test
    void rejectsInvalidIsbn() throws Exception {
        mvc.perform(get("/api/lookup/isbn/{isbn}", "9780000000000").with(owner())).andExpect(status().isBadRequest());
    }
}
