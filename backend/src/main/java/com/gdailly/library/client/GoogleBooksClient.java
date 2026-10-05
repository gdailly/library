package com.gdailly.library.client;

import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.gdailly.library.config.LivreProperties;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/** Google Books volumes API, used when Open Library does not know the ISBN. */
@Component
public class GoogleBooksClient implements MetadataClient {

    private final RestClient http;
    private final JsonMapper json;
    private final String apiKey;

    GoogleBooksClient(LivreProperties properties, JsonMapper json) {
        this.http = HttpClients.restClient(properties.isbn().googleBooksUrl(), properties.isbn().timeout());
        this.json = json;
        this.apiKey = properties.isbn().googleBooksApiKey();
    }

    @Override
    public Optional<String> fetch(String isbn13) {
        String body = http.get()
                .uri(uri -> {
                    uri.path("/books/v1/volumes").queryParam("q", "isbn:" + isbn13);
                    if (apiKey != null && !apiKey.isBlank()) {
                        uri.queryParam("key", apiKey);
                    }
                    return uri.build();
                })
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
        JsonNode info = json.readTree(payload).path("items").path(0).path("volumeInfo");
        String title = BookMetadata.text(info.path("title").asString(null));
        if (title == null) {
            return Optional.empty();
        }
        String authors = info.path("authors").valueStream()
                .map(a -> a.asString(""))
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(", "));
        return Optional.of(new BookMetadata(
                title,
                BookMetadata.text(info.path("subtitle").asString(null)),
                authors.isEmpty() ? null : authors,
                BookMetadata.text(info.path("publisher").asString(null)),
                BookMetadata.parseYear(info.path("publishedDate").asString(null)),
                BookMetadata.positive(info.path("pageCount").asInt(0)),
                BookMetadata.text(info.path("language").asString(null)),
                BookMetadata.text(info.path("description").asString(null)),
                coverUrl(info.path("imageLinks"))));
    }

    /** Largest image offered, over HTTPS and without the page-curl effect. */
    private static String coverUrl(JsonNode links) {
        for (String size : new String[] {"extraLarge", "large", "medium", "small", "thumbnail", "smallThumbnail"}) {
            String url = BookMetadata.text(links.path(size).asString(null));
            if (url != null) {
                return url.replaceFirst("^http://", "https://").replace("&edge=curl", "");
            }
        }
        return null;
    }
}
