package com.gdailly.library.config;

import java.nio.file.Path;
import java.time.Duration;
import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.unit.DataSize;

@ConfigurationProperties(prefix = "livre")
public record LivreProperties(Auth auth, Bootstrap bootstrap, Cors cors, Isbn isbn, Covers covers) {

    public LivreProperties {
        auth = auth != null ? auth : new Auth(List.of());
        bootstrap = bootstrap != null ? bootstrap : new Bootstrap(null, null);
        cors = cors != null ? cors : new Cors(List.of());
        isbn = isbn != null ? isbn : new Isbn(null, null, null, null, null, null);
        covers = covers != null ? covers : new Covers(null, null, null, null);
    }

    /**
     * Cover files and their signed URLs.
     *
     * @param directory  where originals and thumbnails are written (Docker volume {@code covers})
     * @param urlSecret  HMAC key of the cover URLs; required
     * @param urlTtl     how long a signed URL stays valid at least
     * @param maxSize    largest image accepted, uploaded or downloaded
     */
    public record Covers(Path directory, String urlSecret, Duration urlTtl, DataSize maxSize) {
        public Covers {
            directory = directory != null ? directory : Path.of("covers");
            urlTtl = urlTtl != null ? urlTtl : Duration.ofHours(24);
            maxSize = maxSize != null ? maxSize : DataSize.ofMegabytes(5);
        }
    }

    /** OAuth client IDs (web, Android) accepted as the {@code aud} claim of Google ID tokens. */
    public record Auth(List<String> googleClientIds) {
        public Auth {
            googleClientIds = nonBlank(googleClientIds);
        }
    }

    /** First owner, created at startup when no library exists yet. */
    public record Bootstrap(String ownerEmail, String libraryName) {
    }

    public record Cors(List<String> allowedOrigins) {
        public Cors {
            allowedOrigins = nonBlank(allowedOrigins);
        }
    }

    /** ISBN metadata APIs and how long their answers are cached. */
    public record Isbn(
            String openLibraryUrl,
            String googleBooksUrl,
            String googleBooksApiKey,
            Duration timeout,
            Duration foundTtl,
            Duration notFoundTtl) {
        public Isbn {
            openLibraryUrl = openLibraryUrl != null ? openLibraryUrl : "https://openlibrary.org";
            googleBooksUrl = googleBooksUrl != null ? googleBooksUrl : "https://www.googleapis.com";
            timeout = timeout != null ? timeout : Duration.ofSeconds(5);
            foundTtl = foundTtl != null ? foundTtl : Duration.ofDays(180);
            notFoundTtl = notFoundTtl != null ? notFoundTtl : Duration.ofDays(7);
        }
    }

    private static List<String> nonBlank(List<String> values) {
        return values == null ? List.of() : values.stream().map(String::trim).filter(s -> !s.isEmpty()).toList();
    }
}
