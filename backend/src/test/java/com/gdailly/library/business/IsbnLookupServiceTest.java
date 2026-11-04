package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestClientException;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.client.GoogleBooksClient;
import com.gdailly.library.client.OpenLibraryClient;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.IsbnLookupResponse;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.mapper.IsbnLookupMapperImpl;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;

import tools.jackson.databind.json.JsonMapper;

class IsbnLookupServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "alice@example.com", 1L, Role.MEMBER);
    private static final Instant NOW = Instant.parse("2026-10-06T08:00:00Z");
    private static final String ISBN = "9782070612758";
    private static final BookMetadata PETIT_PRINCE =
            new BookMetadata("Le Petit Prince", null, "Antoine de Saint-Exupéry", null, 1943, 96, null, null, null);

    private final LibraryBookRepository books = mock(LibraryBookRepository.class);
    private final IsbnLookupRepository cache = mock(IsbnLookupRepository.class);
    private final OpenLibraryClient openLibrary = mock(OpenLibraryClient.class);
    private final GoogleBooksClient googleBooks = mock(GoogleBooksClient.class);
    private final BnfClient bnf = mock(BnfClient.class);
    private final JsonMapper json = JsonMapper.builder().build();
    private final MetadataSources sources = new MetadataSources(openLibrary, googleBooks, bnf, json);
    private final IsbnLookupService service = new IsbnLookupService(books, cache, sources,
            new LivreProperties(null, null, null, null, null), Clock.fixed(NOW, ZoneOffset.UTC), new IsbnLookupMapperImpl());

    @BeforeEach
    void setUp() {
        when(books.findByLibraryIdAndBookIsbn13(1L, ISBN)).thenReturn(Optional.empty());
        when(cache.findById(ISBN)).thenReturn(Optional.empty());
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.empty());
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.empty());
        when(bnf.fetch(ISBN)).thenReturn(Optional.empty());
        when(openLibrary.parse(ISBN, "ol")).thenReturn(Optional.of(PETIT_PRINCE));
        when(googleBooks.parse(ISBN, "gb")).thenReturn(Optional.of(PETIT_PRINCE));
    }

    @Test
    void refusesInvalidIsbn() {
        assertThatThrownBy(() -> service.lookup(USER, "9782070612759")).isInstanceOf(BadRequestException.class);
        verifyNoInteractions(books, cache, openLibrary, googleBooks, bnf);
    }

    @Test
    void normalisesIsbn10() {
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.of("ol"));
        assertThat(service.lookup(USER, "2-07-061275-9").isbn13()).isEqualTo(ISBN);
    }

    @Test
    void answersFromLibraryWithoutCacheNorApi() {
        Book book = new Book();
        book.setIsbn13(ISBN);
        book.setTitle("Le Petit Prince");
        ReflectionTestUtils.setField(book, "id", 42L);
        when(books.findByLibraryIdAndBookIsbn13(1L, ISBN)).thenReturn(Optional.of(new LibraryBook(1L, book, 7L)));

        IsbnLookupResponse response = service.lookup(USER, ISBN);

        assertThat(response.source()).isEqualTo(MetadataSource.LIBRARY);
        assertThat(response.existingBookId()).isEqualTo(42L);
        verifyNoInteractions(cache, openLibrary, googleBooks, bnf);
    }

    @Test
    void answersFromFreshCacheWithoutApi() {
        cached(LookupSource.GOOGLE_BOOKS, "gb", Duration.ofDays(179));

        IsbnLookupResponse response = service.lookup(USER, ISBN);

        assertThat(response.source()).isEqualTo(MetadataSource.GOOGLE_BOOKS);
        assertThat(response.title()).isEqualTo("Le Petit Prince");
        verify(openLibrary, never()).fetch(anyString());
        verify(googleBooks, never()).fetch(anyString());
    }

    @Test
    void refetchesCacheOlderThan180Days() {
        cached(LookupSource.OPEN_LIBRARY, "old", Duration.ofDays(181));
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.of("ol"));

        assertThat(service.lookup(USER, ISBN).source()).isEqualTo(MetadataSource.OPEN_LIBRARY);
        verify(openLibrary).fetch(ISBN);
    }

    @Test
    void trustsRecentNotFoundFor7Days() {
        cached(LookupSource.NOT_FOUND, null, Duration.ofDays(6));

        assertThatThrownBy(() -> service.lookup(USER, ISBN)).isInstanceOf(NotFoundException.class);
        verify(openLibrary, never()).fetch(anyString());
    }

    @Test
    void retriesNotFoundAfter7Days() {
        cached(LookupSource.NOT_FOUND, null, Duration.ofDays(8));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb"));

        assertThat(service.lookup(USER, ISBN).source()).isEqualTo(MetadataSource.GOOGLE_BOOKS);
    }

    @Test
    void refetchesWhenCachedPayloadIsUnreadable() {
        cached(LookupSource.OPEN_LIBRARY, "garbage", Duration.ofDays(1));
        when(openLibrary.parse(ISBN, "garbage")).thenReturn(Optional.empty());
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.of("ol"));

        assertThat(service.lookup(USER, ISBN).title()).isEqualTo("Le Petit Prince");
    }

    @Test
    void queriesEverySourceAndCachesTheirAnswersTogether() {
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.of("ol"));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb"));

        IsbnLookupResponse response = service.lookup(USER, ISBN);

        assertThat(response.source()).isEqualTo(MetadataSource.OPEN_LIBRARY);
        assertThat(response.existingBookId()).isNull();
        verify(bnf).fetch(ISBN);
        IsbnLookup saved = savedEntry();
        assertThat(saved.getSource()).isEqualTo(LookupSource.OPEN_LIBRARY);
        assertThat(saved.getPayload()).isEqualTo("{\"sources\":{\"OPEN_LIBRARY\":\"ol\",\"GOOGLE_BOOKS\":\"gb\"}}");
        assertThat(saved.getFetchedAt()).isEqualTo(NOW);
    }

    @Test
    void mergesFieldsFromSeveralSources() {
        when(openLibrary.fetch(ISBN)).thenReturn(Optional.of("ol"));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb-rich"));
        when(bnf.fetch(ISBN)).thenReturn(Optional.of("bnf"));
        when(googleBooks.parse(ISBN, "gb-rich")).thenReturn(Optional.of(new BookMetadata("The Little Prince", null,
                "A. de Saint-Exupéry", null, 2000, 93, "fr", "Un pilote...", "https://books.google/cover")));
        when(bnf.parse(ISBN, "bnf")).thenReturn(Optional.of(new BookMetadata("Le petit prince", null,
                "Antoine de Saint-Exupéry", "Gallimard", 1999, null, "fr", null, null)));

        IsbnLookupResponse response = service.lookup(USER, ISBN);

        assertThat(response.source()).isEqualTo(MetadataSource.BNF);
        assertThat(response.title()).isEqualTo("Le petit prince");
        assertThat(response.publisher()).isEqualTo("Gallimard");
        assertThat(response.year()).isEqualTo(1999);
        assertThat(response.pages()).isEqualTo(96); // Open Library
        assertThat(response.summary()).isEqualTo("Un pilote..."); // Google Books
        assertThat(response.coverUrl()).isEqualTo("https://books.google/cover");
    }

    @Test
    void readsMultiSourceCacheEntries() {
        cached(LookupSource.BNF, "{\"sources\":{\"OPEN_LIBRARY\":\"ol\"}}", Duration.ofDays(3));

        assertThat(service.lookup(USER, ISBN).title()).isEqualTo("Le Petit Prince");
        verify(openLibrary, never()).fetch(anyString());
    }

    @Test
    void refreshIgnoresCacheOlderThanTheGivenAge() {
        cached(LookupSource.OPEN_LIBRARY, "ol", Duration.ofDays(2));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb"));

        assertThat(service.refresh(ISBN, Duration.ofDays(1))).isPresent();
        verify(googleBooks).fetch(ISBN);
    }

    @Test
    void refreshesOneSourceAndKeepsTheOthersAnswers() {
        cached(LookupSource.OPEN_LIBRARY, "{\"sources\":{\"OPEN_LIBRARY\":\"ol\",\"GOOGLE_BOOKS\":\"old\"}}", Duration.ofDays(30));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb"));

        assertThat(service.refreshSource(ISBN, LookupSource.GOOGLE_BOOKS)).contains(PETIT_PRINCE);

        verify(openLibrary, never()).fetch(anyString());
        verify(bnf, never()).fetch(anyString());
        assertThat(savedEntry().getPayload()).isEqualTo("{\"sources\":{\"OPEN_LIBRARY\":\"ol\",\"GOOGLE_BOOKS\":\"gb\"}}");
    }

    @Test
    void reportsASourceThatCannotAnswer() {
        when(bnf.fetch(ISBN)).thenThrow(new RestClientException("timeout"));

        assertThatThrownBy(() -> service.refreshSource(ISBN, LookupSource.BNF))
                .isInstanceOf(ServiceUnavailableException.class);
        verify(cache, never()).save(any());
    }

    @Test
    void refreshReusesRecentAnswers() {
        cached(LookupSource.OPEN_LIBRARY, "ol", Duration.ofHours(2));

        assertThat(service.refresh(ISBN, Duration.ofDays(1))).isPresent();
        verify(openLibrary, never()).fetch(anyString());
    }

    @Test
    void cachesNotFoundWhenNoSourceKnowsTheIsbn() {
        assertThatThrownBy(() -> service.lookup(USER, ISBN)).isInstanceOf(NotFoundException.class);

        IsbnLookup saved = savedEntry();
        assertThat(saved.getSource()).isEqualTo(LookupSource.NOT_FOUND);
        assertThat(saved.getPayload()).isNull();
    }

    @Test
    void usesGoogleBooksWhenOpenLibraryIsDown() {
        when(openLibrary.fetch(ISBN)).thenThrow(new RestClientException("timeout"));
        when(googleBooks.fetch(ISBN)).thenReturn(Optional.of("gb"));

        assertThat(service.lookup(USER, ISBN).source()).isEqualTo(MetadataSource.GOOGLE_BOOKS);
    }

    @Test
    void doesNotCacheNotFoundWhenASourceIsDown() {
        when(googleBooks.fetch(ISBN)).thenThrow(new RestClientException("429"));

        assertThatThrownBy(() -> service.lookup(USER, ISBN)).isInstanceOf(ServiceUnavailableException.class);
        verify(cache, never()).save(any());
    }

    private void cached(LookupSource source, String payload, Duration age) {
        when(cache.findById(ISBN)).thenReturn(Optional.of(new IsbnLookup(ISBN, source, payload, NOW.minus(age))));
    }

    private IsbnLookup savedEntry() {
        ArgumentCaptor<IsbnLookup> saved = ArgumentCaptor.forClass(IsbnLookup.class);
        verify(cache).save(saved.capture());
        return saved.getValue();
    }
}
