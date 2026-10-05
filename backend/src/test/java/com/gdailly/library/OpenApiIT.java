package com.gdailly.library;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;

/** Exports the OpenAPI contract to docs/api/openapi.yaml, which the Dart client is generated from. */
class OpenApiIT extends IntegrationTest {

    private static final Path CONTRACT = Path.of("..", "docs", "api", "openapi.yaml");

    @Test
    void exportsContract() throws Exception {
        String yaml = mvc.perform(get("/v3/api-docs.yaml"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        assertThat(yaml).contains("/api/books/{id}", "/api/me");
        if (Files.isDirectory(CONTRACT.getParent())) {
            Files.writeString(CONTRACT, yaml, StandardCharsets.UTF_8);
        }
    }
}
