package com.gdailly.library.business;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.EnumMap;
import java.util.Map;
import java.util.Optional;
import java.util.function.Predicate;

import org.springframework.stereotype.Service;

import com.gdailly.library.client.BookMetadata;
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
 * Finds metadata for an ISBN: the library itself, then the {@code isbn_lookup} cache, then all the external sources
 * (Open Library, Google Books, BnF) whose answers are merged field by field. External APIs are never called while
 * the cache entry is valid. No transaction spans the HTTP calls.
 */
@Service
public class IsbnLookupService {

    private final BookRepository books;
    private final IsbnLookupRepository cache;
    private final MetadataSources sources;
    private final LivreProperties.Isbn settings;
    private final Clock clock;
    private final IsbnLookupMapper isbnLookupMapper;

    IsbnLookupService(BookRepository books, IsbnLookupRepository cache, MetadataSources sources,
            LivreProperties properties, Clock clock, IsbnLookupMapper isbnLookupMapper) {
        this.books = books;
        this.cache = cache;
        this.sources = sources;
        this.settings = properties.isbn();
        this.clock = clock;
        this.isbnLookupMapper = isbnLookupMapper;
    }

    public IsbnLookupResponse lookup(CurrentUser user, String rawIsbn) {
        String isbn13 = Isbn.toIsbn13(rawIsbn).orElseThrow(() -> new BadRequestException("ISBN invalide : " + rawIsbn));

        var existing = books.findByLibraryIdAndIsbn13(user.libraryId(), isbn13);
        if (existing.isPresent()) {
            return isbnLookupMapper.fromBook(existing.get());
        }
        MetadataMerger.Merged merged = resolve(isbn13, this::isFresh).orElseThrow(NotFoundException::new);
        return isbnLookupMapper.fromMetadata(isbn13, MetadataSource.valueOf(merged.source().name()), merged.metadata());
    }

    /**
     * Metadata for a resynchronisation: the cache is used only when it was filled less than {@code maxAge} ago,
     * so that a resynchronisation queries the sources again but a second run the same day does not.
     * Empty when no source knows the ISBN; throws {@link ServiceUnavailableException} when a source could not answer.
     */
    Optional<MetadataMerger.Merged> refresh(String isbn13, Duration maxAge) {
        Instant since = Instant.now(clock).minus(maxAge);
        return resolve(isbn13, entry -> entry.getFetchedAt().isAfter(since));
    }

    private Optional<MetadataMerger.Merged> resolve(String isbn13, Predicate<IsbnLookup> usable) {
        Optional<IsbnLookup> entry = cache.findById(isbn13).filter(usable);
        if (entry.isPresent()) {
            if (entry.get().getSource() == LookupSource.NOT_FOUND) {
                return Optional.empty();
            }
            Optional<MetadataMerger.Merged> cached = MetadataMerger.merge(sources.decode(entry.get()));
            if (cached.isPresent()) {
                return cached;
            }
            // Unreadable payload: the APIs are queried again.
        }

        MetadataSources.Answers answers = sources.fetchAll(isbn13);
        Map<LookupSource, BookMetadata> parsed = sources.parse(isbn13, answers.payloads());
        Optional<MetadataMerger.Merged> merged = MetadataMerger.merge(parsed);
        if (merged.isPresent()) {
            Map<LookupSource, String> known = new EnumMap<>(answers.payloads());
            known.keySet().retainAll(parsed.keySet());
            cache.save(new IsbnLookup(isbn13, merged.get().source(), sources.encode(known), Instant.now(clock)));
            return merged;
        }
        if (answers.incomplete()) {
            // Do not remember "not found" when a source could not answer.
            throw new ServiceUnavailableException("Recherche ISBN momentanément indisponible, réessayez ou saisissez le livre.");
        }
        cache.save(new IsbnLookup(isbn13, LookupSource.NOT_FOUND, null, Instant.now(clock)));
        return Optional.empty();
    }

    private boolean isFresh(IsbnLookup entry) {
        Duration ttl = entry.getSource() == LookupSource.NOT_FOUND ? settings.notFoundTtl() : settings.foundTtl();
        return entry.getFetchedAt().plus(ttl).isAfter(Instant.now(clock));
    }
}
