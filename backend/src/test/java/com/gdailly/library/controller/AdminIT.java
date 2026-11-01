package com.gdailly.library.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import com.gdailly.library.IntegrationTest;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.jayway.jsonpath.JsonPath;

class AdminIT extends IntegrationTest {

    @Autowired
    private IsbnLookupRepository cache;

    @Test
    void completesABookThenReplacesItsFields() throws Exception {
        String isbn = "9780000090027";
        long id = createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Titre saisi\"}");
        METADATA.openLibraryKnows(isbn, "{\"title\": \"Le Titre\", \"authors\": [{\"name\": \"Jeanne Autrice\"}], \"number_of_pages\": 210}");

        mvc.perform(post("/api/admin/metadata/books/{id}/sync", id).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.outcome").value("UPDATED"))
                .andExpect(jsonPath("$.changedFields.length()").value(2))
                .andExpect(jsonPath("$.book.title").value("Titre saisi"))
                .andExpect(jsonPath("$.book.authors").value("Jeanne Autrice"))
                .andExpect(jsonPath("$.book.pages").value(210));

        mvc.perform(post("/api/admin/metadata/books/{id}/sync", id).param("mode", "REPLACE").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.changedFields[0]").value("title"))
                .andExpect(jsonPath("$.book.title").value("Le Titre"));
    }

    @Test
    void resynchronisesTheLibraryInTheBackground() throws Exception {
        String isbn = "9780000090034";
        long id = createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"À compléter\"}");
        METADATA.googleBooksKnows(isbn, "{\"title\": \"Complet\", \"description\": \"Résumé trouvé.\"}");

        mvc.perform(post("/api/admin/metadata/sync").with(owner()))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.total").isNumber());

        for (int i = 0; i < 100; i++) {
            String body = mvc.perform(get("/api/admin/metadata/sync").with(owner()))
                    .andReturn().getResponse().getContentAsString();
            if ("DONE".equals(JsonPath.read(body, "$.state"))) {
                break;
            }
            Thread.sleep(100);
        }
        mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andExpect(jsonPath("$.title").value("À compléter"))
                .andExpect(jsonPath("$.summary").value("Résumé trouvé."));
    }

    @Test
    void clearsRememberedNotFound() throws Exception {
        cache.save(new IsbnLookup("9780000090041", LookupSource.NOT_FOUND, null, Instant.now()));

        mvc.perform(get("/api/admin/metadata").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cachedNotFound").isNumber())
                .andExpect(jsonPath("$.job.state").isString());
        mvc.perform(delete("/api/admin/metadata/cache").with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.deleted").isNumber());
        assertThat(cache.findById("9780000090041")).isEmpty();
    }

    @Test
    void isReservedToOwners() throws Exception {
        var member = member("erin@example.com");
        mvc.perform(get("/api/admin/metadata").with(member)).andExpect(status().isForbidden());
        mvc.perform(post("/api/admin/metadata/sync").with(member)).andExpect(status().isForbidden());
        mvc.perform(delete("/api/admin/metadata/cache").with(member)).andExpect(status().isForbidden());
    }
}
