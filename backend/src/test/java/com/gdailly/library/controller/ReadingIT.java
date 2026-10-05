package com.gdailly.library.controller;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor;

import com.gdailly.library.IntegrationTest;

class ReadingIT extends IntegrationTest {

    @Test
    void readingIsPersonalToEachMember() throws Exception {
        long id = createBook("{\"title\": \"Les Misérables\", \"authors\": \"Victor Hugo\"}");
        JwtRequestPostProcessor alice = member("alice@example.com");

        mvc.perform(put("/api/books/{id}/reading", id).with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"READ\", \"rating\": 5, \"review\": \"Immense.\", \"startedOn\": \"2026-01-02\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("READ"))
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.startedOn").value("2026-01-02"))
                .andExpect(jsonPath("$.finishedOn").value(notNullValue()));

        mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andExpect(jsonPath("$.myReading.review").value("Immense."));
        mvc.perform(get("/api/books/{id}", id).with(alice))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.myReading").doesNotExist());

        mvc.perform(put("/api/books/{id}/reading", id).with(alice).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"READING\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.startedOn").value(notNullValue()))
                .andExpect(jsonPath("$.rating").doesNotExist());
        mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andExpect(jsonPath("$.myReading.status").value("READ"));
    }

    @Test
    void filtersOnMyStatusAndRating() throws Exception {
        long read = createBook("{\"title\": \"Germinal\"}");
        long reading = createBook("{\"title\": \"Nana\"}");
        JwtRequestPostProcessor bob = member("bob@example.com");
        saveReading(bob, read, "{\"status\": \"READ\", \"rating\": 4}");
        saveReading(bob, reading, "{\"status\": \"READING\"}");

        mvc.perform(get("/api/books").param("status", "READ").with(bob))
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Germinal")))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Nana"))));
        mvc.perform(get("/api/books").param("minRating", "4").with(bob))
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Germinal")));
        mvc.perform(get("/api/books").param("minRating", "5").with(bob))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Germinal"))));
        // Bob's readings do not leak into the owner's filters.
        mvc.perform(get("/api/books").param("status", "READ").with(owner()))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Germinal"))));
        mvc.perform(get("/api/books").param("q", "germinal").with(bob))
                .andExpect(jsonPath("$.items[0].myReading.rating").value(4));
    }

    @Test
    void rejectsInvalidReading() throws Exception {
        long id = createBook("{\"title\": \"Bel-Ami\"}");
        mvc.perform(put("/api/books/{id}/reading", id).with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"status\": \"READ\", \"rating\": 6}")).andExpect(status().isBadRequest());
        mvc.perform(put("/api/books/{id}/reading", id).with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"rating\": 3}")).andExpect(status().isBadRequest());
        mvc.perform(put("/api/books/{id}/reading", id).with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"READ\", \"startedOn\": \"2026-03-01\", \"finishedOn\": \"2026-02-01\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(put("/api/books/{id}/reading", 999999).with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"status\": \"READ\"}")).andExpect(status().isNotFound());
        mvc.perform(get("/api/books").param("minRating", "9").with(owner())).andExpect(status().isBadRequest());
    }

    private void saveReading(JwtRequestPostProcessor user, long bookId, String json) throws Exception {
        mvc.perform(put("/api/books/{id}/reading", bookId).with(user).contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isOk());
    }
}
