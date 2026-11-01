package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Sort;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import com.gdailly.library.client.BnfClient;
import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.client.GoogleBooksClient;
import com.gdailly.library.client.OpenLibraryClient;
import com.gdailly.library.dto.ApplyMetadataRequest;
import com.gdailly.library.dto.BookMetadataSummary;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.mapper.IsbnLookupMapperImpl;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;

import tools.jackson.databind.json.JsonMapper;

class MetadataInspectionServiceTest {

    private static final CurrentUser ADMIN = new CurrentUser(7L, "admin@example.com", 1L, Role.OWNER, true);
    private static final String ISBN = "9782070360024";
    private static final BookMetadata BNF = new BookMetadata("L'Étranger", null, "Albert Camus", "Gallimard", 1971,
            191, "fr", null, null);
    private static final BookMetadata GOOGLE = new BookMetadata("L’étranger", null, "Albert Camus", "Folio", 1942,
            159, "fr", "Aujourd'hui, maman est morte.", "https://books.google.com/1");

    private final BookRepository books = mock(BookRepository.class);
    private final IsbnLookupRepository cache = mock(IsbnLookupRepository.class);
    private final OpenLibraryClient openLibrary = mock(OpenLibraryClient.class);
    private final GoogleBooksClient googleBooks = mock(GoogleBooksClient.class);
    private final BnfClient bnf = mock(BnfClient.class);
    private final CoverService covers = mock(CoverService.class);
    private final BookService bookService = mock(BookService.class);
    private final MetadataInspectionService service = new MetadataInspectionService(books, cache,
            new MetadataSources(openLibrary, googleBooks, bnf, JsonMapper.builder().build()), covers, bookService,
            new IsbnLookupMapperImpl(), mock(PlatformTransactionManager.class));

    @Test
    void comparesTheBookWithEverySource() {
        Book book = book();
        assertThat(MetadataInspectionService.differences(book, Map.of(LookupSource.BNF, BNF, LookupSource.GOOGLE_BOOKS, GOOGLE)))
                .containsExactly("publisher", "year", "pages", "summary", "cover");
    }

    @Test
    void ignoresCaseAccentsApostrophesAndSpaces() {
        assertThat(MetadataInspectionService.same("L’Étranger ", "l'etranger")).isTrue();
        assertThat(MetadataInspectionService.same("La Peste", "La Chute")).isFalse();
        assertThat(MetadataInspectionService.same(1971, 1971)).isTrue();
    }

    @Test
    void listsTheBooksWithTheSourcesThatKnowThem() {
        Book book = book();
        when(books.findByLibraryIdAndIsbn13IsNotNull(1L, Sort.by("title", "id"))).thenReturn(List.of(book));
        IsbnLookup entry = cached();
        when(cache.findAllById(List.of(ISBN))).thenReturn(List.of(entry));

        BookMetadataSummary summary = service.list(ADMIN, null, true, 0).items().getFirst();

        assertThat(summary.sources()).containsExactly(MetadataSource.GOOGLE_BOOKS, MetadataSource.BNF);
        assertThat(summary.differences()).contains("summary");
        assertThat(service.list(ADMIN, "zola", false, 0).items()).isEmpty();
    }

    @Test
    void copiesTheChosenFieldsOfOneSource() {
        Book book = book();
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        IsbnLookup entry = cached();
        when(cache.findById(ISBN)).thenReturn(Optional.of(entry));
        when(covers.importFromUrl("https://books.google.com/1")).thenReturn(Optional.of("k".repeat(64)));

        service.apply(ADMIN, 5L, new ApplyMetadataRequest(MetadataSource.GOOGLE_BOOKS, List.of("summary", "cover", "year")));

        assertThat(book.getSummary()).isEqualTo("Aujourd'hui, maman est morte.");
        assertThat(book.getCoverKey()).isEqualTo("k".repeat(64));
        assertThat(book.getYear()).isEqualTo(1942);
        assertThat(book.getPublisher()).isNull();
        verify(bookService).get(any(), any());
    }

    @Test
    void refusesASourceWithoutStoredAnswer() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book()));
        IsbnLookup entry = cached();
        when(cache.findById(ISBN)).thenReturn(Optional.of(entry));

        assertThatThrownBy(() -> service.apply(ADMIN, 5L,
                new ApplyMetadataRequest(MetadataSource.OPEN_LIBRARY, List.of("title"))))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void isReservedToTheAdministrator() {
        CurrentUser owner = new CurrentUser(8L, "owner@example.com", 1L, Role.OWNER);
        assertThatThrownBy(() -> service.list(owner, null, false, 0)).isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.get(owner, 5L)).isInstanceOf(ForbiddenException.class);
    }

    private IsbnLookup cached() {
        when(bnf.parse(ISBN, "bnf")).thenReturn(Optional.of(BNF));
        when(googleBooks.parse(ISBN, "gb")).thenReturn(Optional.of(GOOGLE));
        return new IsbnLookup(ISBN, LookupSource.BNF, "{\"sources\":{\"BNF\":\"bnf\",\"GOOGLE_BOOKS\":\"gb\"}}",
                Instant.parse("2026-11-01T20:00:00Z"));
    }

    private static Book book() {
        Book book = new Book(1L, 7L);
        ReflectionTestUtils.setField(book, "id", 5L);
        book.setIsbn13(ISBN);
        book.setTitle("L'étranger");
        book.setAuthors("Albert Camus");
        book.setLanguage("fr");
        return book;
    }
}
