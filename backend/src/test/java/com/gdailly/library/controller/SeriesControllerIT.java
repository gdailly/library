package com.gdailly.library.controller;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import com.gdailly.library.IntegrationTest;

class SeriesControllerIT extends IntegrationTest {

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
    void requiresASeriesName() throws Exception {
        mvc.perform(get("/api/series/books").param("name", " ").with(owner())).andExpect(status().isBadRequest());
        mvc.perform(get("/api/series").with(googleUser("stranger@example.com"))).andExpect(status().isForbidden());
    }

    private void create(String body) throws Exception {
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated());
    }
}
