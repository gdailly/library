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

class CategoryControllerIT extends IntegrationTest {

    @Test
    void managesCategories() throws Exception {
        long id = createCategory("Poésie", "#1f5e4b");
        mvc.perform(get("/api/categories").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.id == " + id + ")].color").value(hasItem("#1F5E4B")));

        mvc.perform(post("/api/categories").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"poésie\", \"color\": \"#000000\"}")).andExpect(status().isConflict());
        mvc.perform(post("/api/categories").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Théâtre\", \"color\": \"red\"}")).andExpect(status().isBadRequest());

        mvc.perform(put("/api/categories/{id}", id).with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Poèmes\", \"color\": \"#D99A2B\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Poèmes"));
    }

    @Test
    void attachesCategoriesToBooksAndFilters() throws Exception {
        long sf = createCategory("Science-fiction", "#2B5D8A");
        long classic = createCategory("Classiques", "#8A2A1B");
        long book = createBook("{\"title\": \"Hypérion\", \"categoryIds\": [" + sf + ", " + classic + "]}");
        createBook("{\"title\": \"Madame Bovary\", \"categoryIds\": [" + classic + "]}");

        mvc.perform(get("/api/categories").with(owner()))
                .andExpect(jsonPath("$[?(@.id == " + classic + ")].bookCount").value(hasItem(2)))
                .andExpect(jsonPath("$[?(@.id == " + sf + ")].bookCount").value(hasItem(1)));

        mvc.perform(get("/api/books/{id}", book).with(owner()))
                .andExpect(jsonPath("$.categories[0].name").value("Classiques"))
                .andExpect(jsonPath("$.categories[1].name").value("Science-fiction"));

        mvc.perform(get("/api/books").param("category", String.valueOf(sf)).with(owner()))
                .andExpect(jsonPath("$.items[*].title").value(hasItem("Hypérion")))
                .andExpect(jsonPath("$.items[*].title").value(not(hasItem("Madame Bovary"))));

        // Deleting a category keeps the book and only removes the link.
        mvc.perform(delete("/api/categories/{id}", sf).with(owner())).andExpect(status().isNoContent());
        mvc.perform(get("/api/books/{id}", book).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.categories.length()").value(1));
    }

    @Test
    void rejectsUnknownCategoryOnBook() throws Exception {
        mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\": \"Orphelin\", \"categoryIds\": [999999]}")).andExpect(status().isBadRequest());
    }

    private long createCategory(String name, String color) throws Exception {
        String body = mvc.perform(post("/api/categories").with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"" + name + "\", \"color\": \"" + color + "\"}"))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(body, "$.id")).longValue();
    }
}
