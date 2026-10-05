package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.gdailly.library.client.GoogleBooksClient;
import com.gdailly.library.client.MetadataClient;
import com.gdailly.library.client.OpenLibraryClient;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.IsbnLookupResponse;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.mapper.IsbnLookupMapper;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Isbn;

/**
 * Finds metadata for an ISBN: the library itself, then the {@code isbn_lookup} cache, then Open Library,
 * then Google Books. External APIs are never called while the cache entry is valid.
 * No transaction spans the HTTP calls.
 */
@Service
public class IsbnLookupService {

    private static final Logger log = LoggerFactory.getLogger(IsbnLookupService.class);

    private final BookRepository books;
    private final IsbnLookupRepository cache;
    private final OpenLibraryClient openLibrary;
    private final GoogleBooksClient googleBooks;
    private final LivreProperties.Isbn settings;
    private final Clock clock;

    IsbnLookupService(BookRepository books, IsbnLookupRepository cache, OpenLibraryClient openLibrary,
            GoogleBooksClient googleBooks, LivreProperties properties, Clock clock) {
        this.books = books;
        this.cache = cache;
        this.openLibrary = openLibrary;
        this.googleBooks = googleBooks;
        this.settings = properties.isbn();
        this.clock = clock;
    }

    public IsbnLookupResponse lookup(CurrentUser user, String rawIsbn) {
        String isbn13 = Isbn.toIsbn13(rawIsbn).orElseThrow(() -> new BadRequestException("ISBN invalide : " + rawIsbn));

        var existing = books.findByLibraryIdAndIsbn13(user.libraryId(), isbn13);
        if (existing.isPresent()) {
            return IsbnLookupMapper.fromBook(existing.get());
        }

        Optional<IsbnLookup> entry = cache.findById(isbn13).filter(this::isFresh);
        if (entry.isPresent()) {
            if (entry.get().getSource() == LookupSource.NOT_FOUND) {
                throw new NotFoundException();
            }
            Optional<IsbnLookupResponse> cached = fromCache(entry.get());
            if (cached.isPresent()) {
                return cached.get();
            }
        }

        boolean failed = false;
        for (Source source : new Source[] {
                new Source(openLibrary, LookupSource.OPEN_LIBRARY, MetadataSource.OPEN_LIBRARY),
                new Source(googleBooks, LookupSource.GOOGLE_BOOKS, MetadataSource.GOOGLE_BOOKS)}) {
            try {
                Optional<String> payload = source.client().fetch(isbn13);
                if (payload.isPresent()) {
                    cache.save(new IsbnLookup(isbn13, source.cached(), payload.get(), Instant.now(clock)));
                    return IsbnLookupMapper.fromMetadata(isbn13, source.reported(),
                            source.client().parse(isbn13, payload.get()).orElseThrow());
                }
            } catch (RuntimeException e) {
                failed = true;
                log.warn("ISBN lookup of {} on {} failed: {}", isbn13, source.cached(), e.toString());
            }
        }
        if (failed) {
            // Do not remember "not found" when a source could not answer.
            throw new ServiceUnavailableException("Recherche ISBN momentanément indisponible, réessayez ou saisissez le livre.");
        }
        cache.save(new IsbnLookup(isbn13, LookupSource.NOT_FOUND, null, Instant.now(clock)));
        throw new NotFoundException();
    }

    private boolean isFresh(IsbnLookup entry) {
        Duration ttl = entry.getSource() == LookupSource.NOT_FOUND ? settings.notFoundTtl() : settings.foundTtl();
        return entry.getFetchedAt().plus(ttl).isAfter(Instant.now(clock));
    }

    /** Empty when the cached payload can no longer be read: the APIs are then queried again. */
    private Optional<IsbnLookupResponse> fromCache(IsbnLookup entry) {
        String isbn13 = entry.getIsbn13();
        boolean google = entry.getSource() == LookupSource.GOOGLE_BOOKS;
        MetadataClient client = google ? googleBooks : openLibrary;
        MetadataSource source = google ? MetadataSource.GOOGLE_BOOKS : MetadataSource.OPEN_LIBRARY;
        return client.parse(isbn13, entry.getPayload()).map(m -> IsbnLookupMapper.fromMetadata(isbn13, source, m));
    }

    private record Source(MetadataClient client, LookupSource cached, MetadataSource reported) {
    }
}
