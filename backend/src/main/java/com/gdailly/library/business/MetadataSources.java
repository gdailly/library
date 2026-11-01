package com.gdailly.library.business;

import java.util.EnumMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.client.GoogleBooksClient;
import com.gdailly.library.client.MetadataClient;
import com.gdailly.library.client.OpenLibraryClient;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ObjectNode;

/**
 * The external metadata APIs, queried together, and the format of their answers in the {@code isbn_lookup} cache:
 * {@code {"sources": {"OPEN_LIBRARY": "<raw answer>", "BNF": "<raw answer>"}}}. Rows written before the BnF was
 * added hold the raw answer of their single source.
 */
@Component
class MetadataSources {

    private static final Logger log = LoggerFactory.getLogger(MetadataSources.class);
    private static final String SOURCES = "sources";

    private final Map<LookupSource, MetadataClient> clients = new LinkedHashMap<>();
    private final JsonMapper json;

    MetadataSources(OpenLibraryClient openLibrary, GoogleBooksClient googleBooks, BnfClient bnf, JsonMapper json) {
        clients.put(LookupSource.OPEN_LIBRARY, openLibrary);
        clients.put(LookupSource.GOOGLE_BOOKS, googleBooks);
        clients.put(LookupSource.BNF, bnf);
        this.json = json;
    }

    /**
     * Raw answers of the sources that know the ISBN, all queried in parallel.
     * {@code incomplete} is true when a source could not answer (network or server error).
     */
    record Answers(Map<LookupSource, String> payloads, boolean incomplete) {
    }

    Answers fetchAll(String isbn13) {
        Map<LookupSource, Future<Optional<String>>> calls = new EnumMap<>(LookupSource.class);
        Map<LookupSource, String> payloads = new EnumMap<>(LookupSource.class);
        boolean incomplete = false;
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            clients.forEach((source, client) -> calls.put(source, executor.submit(() -> client.fetch(isbn13))));
            for (var call : calls.entrySet()) {
                try {
                    call.getValue().get().ifPresent(payload -> payloads.put(call.getKey(), payload));
                } catch (ExecutionException e) {
                    incomplete = true;
                    log.warn("ISBN lookup of {} on {} failed: {}", isbn13, call.getKey(), e.getCause().toString());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    throw new IllegalStateException("Interrupted ISBN lookup", e);
                }
            }
        }
        return new Answers(payloads, incomplete);
    }

    String encode(Map<LookupSource, String> payloads) {
        ObjectNode root = json.createObjectNode();
        ObjectNode sources = root.putObject(SOURCES);
        payloads.forEach((source, payload) -> sources.put(source.name(), payload));
        return json.writeValueAsString(root);
    }

    /** Understood answers of a cached entry; empty when it is NOT_FOUND or can no longer be read. */
    Map<LookupSource, BookMetadata> decode(IsbnLookup entry) {
        if (entry.getSource() == LookupSource.NOT_FOUND || entry.getPayload() == null) {
            return new EnumMap<>(LookupSource.class);
        }
        Map<LookupSource, String> payloads = new EnumMap<>(LookupSource.class);
        JsonNode sources = sourcesOf(entry.getPayload());
        if (sources == null) {
            payloads.put(entry.getSource(), entry.getPayload());
        } else {
            for (var source : sources.properties()) {
                try {
                    payloads.put(LookupSource.valueOf(source.getKey()), source.getValue().asString());
                } catch (IllegalArgumentException e) {
                    log.warn("Unknown source {} in cached lookup of {}", source.getKey(), entry.getIsbn13());
                }
            }
        }
        return parse(entry.getIsbn13(), payloads);
    }

    /** The "sources" object of a multi-source payload; null for a single raw answer (older rows). */
    private JsonNode sourcesOf(String payload) {
        try {
            JsonNode sources = json.readTree(payload).path(SOURCES);
            return sources.isObject() ? sources : null;
        } catch (RuntimeException e) {
            return null;
        }
    }

    Map<LookupSource, BookMetadata> parse(String isbn13, Map<LookupSource, String> payloads) {
        Map<LookupSource, BookMetadata> answers = new EnumMap<>(LookupSource.class);
        payloads.forEach((source, payload) -> {
            MetadataClient client = clients.get(source);
            if (client == null) {
                return;
            }
            try {
                client.parse(isbn13, payload).ifPresent(metadata -> answers.put(source, metadata));
            } catch (RuntimeException e) {
                log.warn("Unreadable {} answer for {}: {}", source, isbn13, e.toString());
            }
        });
        return answers;
    }
}
