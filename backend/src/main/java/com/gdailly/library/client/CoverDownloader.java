package com.gdailly.library.client;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.net.URI;
import java.util.Optional;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.gdailly.library.config.LivreProperties;

/** Downloads a cover image offered by a metadata API. */
@Component
public class CoverDownloader {

    private final RestClient http;
    private final long maxBytes;

    CoverDownloader(LivreProperties properties) {
        this.http = HttpClients.restClient(null, properties.isbn().timeout());
        this.maxBytes = properties.covers().maxSize().toBytes();
    }

    /** Image bytes; empty for a non-HTTP(S) URL or an image over the size limit. Throws on network errors. */
    public Optional<byte[]> download(String url) {
        URI uri = URI.create(url);
        if (!"https".equals(uri.getScheme()) && !"http".equals(uri.getScheme())) {
            return Optional.empty();
        }
        return http.get().uri(uri).exchange((request, response) -> {
            if (!response.getStatusCode().is2xxSuccessful()) {
                return Optional.empty();
            }
            try (InputStream body = response.getBody()) {
                byte[] bytes = body.readNBytes((int) maxBytes + 1);
                return bytes.length > maxBytes ? Optional.<byte[]>empty() : Optional.of(bytes);
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        });
    }
}
