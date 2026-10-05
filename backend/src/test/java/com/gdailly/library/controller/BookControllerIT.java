package com.gdailly.library.controller;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import com.gdailly.library.IntegrationTest;
import com.jayway.jsonpath.JsonPath;

class BookControllerIT extends IntegrationTest {

    @Test
    void createsReadsUpdatesAndDeletesBook() throws Exception {
        String created = mvc.perform(post("/api/books").with(owner())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"isbn": "2-07-061275-9", "title": "Le Petit Prince", "authors": "Antoine de Saint-Exupéry",
                                 "year": 1943, "pages": 96, "language": "fr"}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.isbn13").value("9782070612758"))
                .andExpect(jsonPath("$.owned").value(true))
                .andReturn().getResponse().getContentAsString();
        int id = JsonPath.read(created, "$.id");

        mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Le Petit Prince"));

        mvc.perform(put("/api/books/{id}", id).with(owner())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"isbn": "9782070612758", "title": "Le Petit Prince", "owned": false}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.owned").value(false))
                .andExpect(jsonPath("$.authors").doesNotExist());

        mvc.perform(delete("/api/books/{id}", id).with(owner())).andExpect(status().isNoContent());
        mvc.perform(get("/api/books/{id}", id).with(owner())).andExpect(status().isNotFound());
    }

    @Test
    void rejectsDuplicateIsbnAndInvalidInput() throws Exception {
        String body = """
                {"isbn": "978-0-306-40615-7", "title": "Signals"}
                """;
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated());
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isConflict());

        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isbn\": \"9780306406158\", \"title\": \"Bad check digit\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\": \"  \"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void searchesByTextAndOwnership() throws Exception {
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\": \"Dune\", \"authors\": \"Frank Herbert\"}")).andExpect(status().isCreated());
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\": \"Fondation\", \"authors\": \"Isaac Asimov\", \"owned\": false}")).andExpect(status().isCreated());

        mvc.perform(get("/api/books").param("q", "herbert").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Dune")))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Fondation"))));

        mvc.perform(get("/api/books").param("owned", "false").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Fondation")))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Dune"))));
    }

    @Test
    void hidesBooksFromNonMembers() throws Exception {
        mvc.perform(get("/api/books").with(googleUser("stranger@example.com"))).andExpect(status().isForbidden());
    }
}
