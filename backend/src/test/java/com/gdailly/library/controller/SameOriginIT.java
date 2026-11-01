package com.gdailly.library.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import com.gdailly.library.IntegrationTest;

/** The web app is served by Caddy from the API's own origin, over HTTPS terminated in front of the backend. */
class SameOriginIT extends IntegrationTest {

    @Test
    void acceptsWritesFromTheAppOwnOriginBehindTheProxy() throws Exception {
        mvc.perform(post("/api/categories").with(owner())
                        .header("Host", "livre.example.org")
                        .header("Origin", "https://livre.example.org")
                        .header("X-Forwarded-Proto", "https")
                        .header("X-Forwarded-Host", "livre.example.org")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Même origine\", \"color\": \"#3E6B48\"}"))
                .andExpect(status().isCreated());
    }

    @Test
    void stillRejectsOtherOrigins() throws Exception {
        mvc.perform(post("/api/categories").with(owner())
                        .header("Host", "livre.example.org")
                        .header("Origin", "https://evil.example.com")
                        .header("X-Forwarded-Proto", "https")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Autre origine\", \"color\": \"#3E6B48\"}"))
                .andExpect(status().isForbidden());
    }
}
