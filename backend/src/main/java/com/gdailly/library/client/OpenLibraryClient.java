package com.gdailly.library.client;

import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.gdailly.library.config.LivreProperties;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/** Open Library "books" API: {@code /api/books?bibkeys=ISBN:...&jscmd=data}. */
@Component
public class OpenLibraryClient implements MetadataClient {

    private final RestClient http;
    private final JsonMapper json;

    OpenLibraryClient(LivreProperties properties, JsonMapper json) {
        this.http = HttpClients.restClient(properties.isbn().openLibraryUrl(), properties.isbn().timeout());
        this.json = json;
    }

    @Override
    public Optional<String> fetch(String isbn13) {
        String body = http.get()
                .uri("/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data", isbn13)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .body(String.class);
        return parse(isbn13, body).isPresent() ? Optional.of(body) : Optional.empty();
    }

    @Override
    public Optional<BookMetadata> parse(String isbn13, String payload) {
        if (payload == null || payload.isBlank()) {
            return Optional.empty();
        }
        JsonNode book = json.readTree(payload).path("ISBN:" + isbn13);
        String title = BookMetadata.text(book.path("title").asString(null));
        if (title == null) {
            return Optional.empty();
        }
        return Optional.of(new BookMetadata(
                title,
                BookMetadata.text(book.path("subtitle").asString(null)),
                joinNames(book.path("authors")),
                publisher(book.path("publishers").path(0).path("name").asString(null)),
                BookMetadata.parseYear(book.path("publish_date").asString(null)),
                BookMetadata.positive(book.path("number_of_pages").asInt(0)),
                null,
                null,
                BookMetadata.text(book.path("cover").path("large").asString(null))));
    }

    /** Library catalogues bracket inferred values: "[Librairie Générale Française]". */
    static String publisher(String name) {
        String text = BookMetadata.text(name);
        if (text != null && text.startsWith("[") && text.endsWith("]")) {
            return BookMetadata.text(text.substring(1, text.length() - 1));
        }
        return text;
    }

    private static String joinNames(JsonNode authors) {
        String names = authors.valueStream()
                .map(a -> a.path("name").asString(""))
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(", "));
        return names.isEmpty() ? null : names;
    }
}
