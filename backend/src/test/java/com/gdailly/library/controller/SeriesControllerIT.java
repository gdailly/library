package com.gdailly.library.controller;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import com.gdailly.library.IntegrationTest;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.SeriesCatalogStatus;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.SeriesRepository;

class SeriesControllerIT extends IntegrationTest {

    @Autowired
    private SeriesRepository seriesRepository;

    @Autowired
    private BookRepository books;

    @Autowired
    private org.springframework.transaction.PlatformTransactionManager transactionManager;

    @Test
    void showsWhatTheLibraryHasOfASeriesAndWhatIsMissing() throws Exception {
        create("{\"title\": \"Le Lotus bleu\", \"series\": \"Les Aventures de Tintin Test\", \"seriesNumber\": 5}");
        create("{\"title\": \"Tintin au Congo\", \"series\": \"Les aventures de tintin test\", \"seriesNumber\": 2}");
        create("{\"title\": \"Le Sceptre d'Ottokar\", \"series\": \"Les Aventures de Tintin Test\", \"seriesNumber\": 8,"
                + " \"owned\": false}");

        mvc.perform(get("/api/series").param("q", "tintin test").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Les Aventures de Tintin Test"))
                .andExpect(jsonPath("$[0].books").value(3))
                .andExpect(jsonPath("$[0].owned").value(2))
                .andExpect(jsonPath("$[0].ownedNumbers").value(contains(2, 5)))
                .andExpect(jsonPath("$[0].wishedNumbers").value(contains(8)))
                .andExpect(jsonPath("$[0].missingNumbers").value(contains(1, 3, 4, 6, 7, 8)))
                .andExpect(jsonPath("$[0].lastNumber").value(8));

        mvc.perform(get("/api/series/books").param("name", "les aventures de tintin test").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].title").value(contains("Tintin au Congo", "Le Lotus bleu", "Le Sceptre d'Ottokar")))
                .andExpect(jsonPath("$[0].seriesNumber").value(2));

        mvc.perform(get("/api/books").param("q", "tintin test").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Le Lotus bleu")));
    }

    @Test
    void showsEveryVolumeListedByTheBnfWithTheLibrarysBooks() throws Exception {
        create("{\"title\": \"Tome deux\", \"series\": \"Saga Catalogue Test\", \"seriesNumber\": 2}");
        Instant now = Instant.parse("2026-11-03T20:00:00Z");
        // What listing the series from the BnF leaves: the volumes the library lacks become books of the series.
        new org.springframework.transaction.support.TransactionTemplate(transactionManager).executeWithoutResult(tx -> {
            Series series = seriesRepository.findByNameKey("saga catalogue test").orElseThrow();
            series.listed(SeriesCatalogStatus.FOUND, "123456", now);
            bnfVolume(series, 1, "Tome un", "9782070612758", 2001);
            bnfVolume(series, 3, "Tome trois", null, 2003);
        });

        mvc.perform(get("/api/series").param("q", "saga catalogue").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].catalogVolumes").value(3))
                .andExpect(jsonPath("$[0].missingNumbers").value(contains(1, 3)));

        mvc.perform(get("/api/series/volumes").param("name", "Saga catalogue test").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.volumes[*].number").value(contains(1, 2, 3)))
                .andExpect(jsonPath("$.volumes[0].title").value("Tome un"))
                .andExpect(jsonPath("$.volumes[0].books").isEmpty())
                .andExpect(jsonPath("$.volumes[0].coverUrl").value(
                        "https://covers.openlibrary.org/b/isbn/9782070612758-M.jpg?default=false"))
                .andExpect(jsonPath("$.volumes[1].books[0].title").value("Tome deux"))
                .andExpect(jsonPath("$.volumes[1].coverUrl").doesNotExist())
                .andExpect(jsonPath("$.catalogFetchedAt").exists());

        mvc.perform(get("/api/series/volumes").param("name", "inconnue").with(owner())).andExpect(status().isNotFound());
    }

    @Test
    void requiresASeriesName() throws Exception {
        mvc.perform(get("/api/series/books").param("name", " ").with(owner())).andExpect(status().isBadRequest());
        mvc.perform(get("/api/series").with(googleUser("stranger@example.com"))).andExpect(status().isForbidden());
    }

    @Test
    void letsTheAdministratorListASeriesAgain() throws Exception {
        create("{\"title\": \"Sans ISBN\", \"series\": \"Saga Forcée Test\", \"seriesNumber\": 2}");

        mvc.perform(post("/api/admin/series/sync-one").param("name", "saga forcée test").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.volumes[*].number").value(contains(1, 2)))
                .andExpect(jsonPath("$.catalogFetchedAt").exists());
        // No book of the series has a BnF answer: nothing links to a series record.
        org.assertj.core.api.Assertions.assertThat(seriesRepository.findByNameKey("saga forcee test").orElseThrow().getStatus())
                .isEqualTo(SeriesCatalogStatus.NO_REFERENCE);

        mvc.perform(post("/api/admin/series/sync-one").param("name", "inconnue").with(owner()))
                .andExpect(status().isNotFound());

        mvc.perform(post("/api/admin/series/sync").with(owner()))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.total").isNumber());
        for (int i = 0; i < 100; i++) {
            String body = mvc.perform(get("/api/admin/series/sync").with(owner()))
                    .andReturn().getResponse().getContentAsString();
            if ("DONE".equals(com.jayway.jsonpath.JsonPath.read(body, "$.state"))) {
                return;
            }
            Thread.sleep(100);
        }
        throw new AssertionError("The series listing did not finish");
    }

    @Test
    void reservesTheForcedListingToTheAdministrator() throws Exception {
        var member = member("frank@example.com");
        mvc.perform(post("/api/admin/series/sync").with(member)).andExpect(status().isForbidden());
        mvc.perform(get("/api/admin/series/sync").with(member)).andExpect(status().isForbidden());
        mvc.perform(post("/api/admin/series/sync-one").param("name", "x").with(member)).andExpect(status().isForbidden());
    }

    private void bnfVolume(Series series, int number, String title, String isbn13, int year) {
        Book book = new Book();
        book.setTitle(title);
        book.setIsbn13(isbn13);
        book.setYear(year);
        book.getSeriesLinks().add(new BookSeries(book, series, number));
        books.save(book);
    }

    private void create(String body) throws Exception {
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated());
    }
}
