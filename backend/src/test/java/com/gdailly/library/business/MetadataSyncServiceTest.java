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
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.PlatformTransactionManager;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.BookSyncResponse;
import com.gdailly.library.dto.CacheScope;
import com.gdailly.library.dto.MetadataSyncJobResponse;
import com.gdailly.library.dto.SyncMode;
import com.gdailly.library.dto.SyncOutcome;
import com.gdailly.library.dto.SyncState;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;

class MetadataSyncServiceTest {

    private static final CurrentUser ADMIN = new CurrentUser(7L, "owner@example.com", 1L, Role.OWNER, true);
    private static final CurrentUser OTHER_OWNER = new CurrentUser(8L, "member@example.com", 1L, Role.OWNER);
    private static final String ISBN = "9782070360024";
    private static final BookMetadata FOUND = new BookMetadata("L'Étranger", null, "Albert Camus", "Gallimard", 1971,
            191, "fr", "Aujourd'hui, maman est morte.", "https://books.google.com/1");

    private final BookRepository books = mock(BookRepository.class);
    private final IsbnLookupRepository isbnCache = mock(IsbnLookupRepository.class);
    private final IsbnLookupService lookups = mock(IsbnLookupService.class);
    private final CoverService covers = mock(CoverService.class);
    private final BookService bookService = mock(BookService.class);
    private final SyncHistoryService history = mock(SyncHistoryService.class);
    private final MetadataSyncService service = new MetadataSyncService(books, isbnCache, lookups, covers, bookService, history,
            mock(PlatformTransactionManager.class), Clock.fixed(Instant.parse("2026-11-01T20:00:00Z"), ZoneOffset.UTC),
            new LivreProperties(null, null, null,
                    new LivreProperties.Isbn(null, null, null, null, null, null, null, Duration.ZERO), null));

    @AfterEach
    void stopWorker() {
        service.stop();
    }

    @Test
    void fillCompletesOnlyEmptyFields() {
        Book book = book("L'étranger (poche)", null);
        book.setPublisher(" ");

        List<String> changed = MetadataSyncService.apply(book, FOUND, "k".repeat(64), SyncMode.FILL);

        assertThat(changed).containsExactly("authors", "publisher", "year", "pages", "language", "summary", "cover");
        assertThat(book.getTitle()).isEqualTo("L'étranger (poche)");
        assertThat(book.getPublisher()).isEqualTo("Gallimard");
        assertThat(book.getCoverKey()).isEqualTo("k".repeat(64));
    }

    @Test
    void replaceOverwritesWithKnownValuesButNeverErases() {
        Book book = book("L'étranger (poche)", "c".repeat(64));
        book.setSubtitle("roman");
        book.setYear(1971);

        List<String> changed = MetadataSyncService.apply(book, FOUND, null, SyncMode.REPLACE);

        assertThat(changed).containsExactly("title", "authors", "publisher", "pages", "language", "summary");
        assertThat(book.getTitle()).isEqualTo("L'Étranger");
        assertThat(book.getSubtitle()).isEqualTo("roman");
        assertThat(book.getCoverKey()).isEqualTo("c".repeat(64));
    }

    @Test
    void syncsOneBookAndDownloadsMissingCover() {
        Book book = book("Brouillon", null);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(lookups.refresh(ISBN, MetadataSyncService.REUSE_RECENT_LOOKUPS)).thenReturn(merged());
        when(covers.importFromIsbn(ISBN)).thenReturn(Optional.of("k".repeat(64)));

        BookSyncResponse response = service.syncBook(ADMIN, 5L, SyncMode.FILL, null);

        assertThat(response.outcome()).isEqualTo(SyncOutcome.UPDATED);
        assertThat(response.changedFields()).contains("authors", "cover").doesNotContain("title");
        verify(bookService).get(ADMIN, 5L);
    }

    @Test
    void keepsExistingCoverWhenFilling() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book("Brouillon", "c".repeat(64))));
        when(lookups.refresh(anyString(), any())).thenReturn(merged());

        service.syncBook(ADMIN, 5L, SyncMode.FILL, null);

        verify(covers, never()).importFromIsbn(anyString());
    }

    @Test
    void reportsIsbnUnknownToEverySource() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book("Brouillon", null)));
        when(lookups.refresh(anyString(), any())).thenReturn(Optional.empty());

        assertThat(service.syncBook(ADMIN, 5L, SyncMode.REPLACE, null).outcome()).isEqualTo(SyncOutcome.NOT_FOUND);
    }

    @Test
    void fetchOnlyRefreshesTheSources() {
        Book book = book("Brouillon", null);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(lookups.refresh(anyString(), any())).thenReturn(merged());

        assertThat(service.syncBook(ADMIN, 5L, SyncMode.FETCH, null).changedFields()).isEmpty();
        assertThat(book.getAuthors()).isNull();
        verify(covers, never()).importFromIsbn(anyString());
    }

    @Test
    void usesOnlyTheChosenSource() {
        Book book = book("Brouillon", null);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(lookups.refreshSource(ISBN, LookupSource.GOOGLE_BOOKS)).thenReturn(Optional.of(FOUND));
        when(covers.importFromUrl(FOUND.coverUrl())).thenReturn(Optional.of("g".repeat(64)));

        service.syncBook(ADMIN, 5L, SyncMode.REPLACE, LookupSource.GOOGLE_BOOKS);

        assertThat(book.getTitle()).isEqualTo("L'Étranger");
        assertThat(book.getCoverKey()).isEqualTo("g".repeat(64));
        verify(lookups, never()).refresh(anyString(), any());
    }

    @Test
    void refusesToReplaceTheWholeLibrary() {
        assertThatThrownBy(() -> service.startSyncAll(ADMIN, SyncMode.REPLACE)).isInstanceOf(BadRequestException.class);
    }

    @Test
    void refusesBookWithoutIsbn() {
        Book book = new Book(1L, 7L);
        book.setTitle("Manuscrit");
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));

        assertThatThrownBy(() -> service.syncBook(ADMIN, 5L, SyncMode.FILL, null)).isInstanceOf(BadRequestException.class);
    }

    @Test
    void isReservedToTheAdministratorEvenAmongOwners() {
        assertThatThrownBy(() -> service.syncBook(OTHER_OWNER, 5L, SyncMode.FILL, null)).isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.startSyncAll(OTHER_OWNER, SyncMode.FILL)).isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.clearCache(OTHER_OWNER, CacheScope.ALL)).isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.overview(OTHER_OWNER)).isInstanceOf(ForbiddenException.class);
        verifyNoInteractions(books, isbnCache, lookups);
    }

    @Test
    void clearsNotFoundEntriesOrTheWholeCache() {
        when(isbnCache.deleteAllBySource(LookupSource.NOT_FOUND)).thenReturn(3);
        when(isbnCache.deleteAllEntries()).thenReturn(12);

        assertThat(service.clearCache(ADMIN, CacheScope.NOT_FOUND).deleted()).isEqualTo(3);
        assertThat(service.clearCache(ADMIN, CacheScope.ALL).deleted()).isEqualTo(12);
    }

    @Test
    void resynchronisesTheWholeLibraryInTheBackground() throws InterruptedException {
        assertThat(service.status(ADMIN).state()).isEqualTo(SyncState.IDLE);
        when(books.findIdsWithIsbn(1L)).thenReturn(List.of(1L, 2L, 3L));
        when(books.findByIdAndLibraryId(1L, 1L)).thenReturn(Optional.of(book("Brouillon", null)));
        when(books.findByIdAndLibraryId(2L, 1L)).thenReturn(Optional.of(book("Autre", "c".repeat(64))));
        when(books.findByIdAndLibraryId(3L, 1L)).thenReturn(Optional.of(book("Inconnu", null)));
        when(lookups.refresh(ISBN, MetadataSyncService.REUSE_RECENT_LOOKUPS))
                .thenReturn(merged())
                .thenReturn(Optional.empty())
                .thenThrow(new ServiceUnavailableException("down"));

        MetadataSyncJobResponse started = service.startSyncAll(ADMIN, SyncMode.FILL);
        assertThat(started.state()).isEqualTo(SyncState.RUNNING);
        assertThat(started.total()).isEqualTo(3);

        MetadataSyncJobResponse done = waitForEnd();
        assertThat(done.processed()).isEqualTo(3);
        assertThat(done.updated()).isEqualTo(1);
        assertThat(done.notFound()).isEqualTo(1);
        assertThat(done.failed()).isEqualTo(1);
        assertThat(done.finishedAt()).isNotNull();
    }

    @Test
    void runsOneFullResynchronisationAtATime() {
        when(books.findIdsWithIsbn(1L)).thenReturn(List.of(1L));
        when(books.findByIdAndLibraryId(1L, 1L)).thenAnswer(invocation -> {
            Thread.sleep(500);
            return Optional.of(book("Lent", null));
        });

        service.startSyncAll(ADMIN, SyncMode.FILL);

        assertThatThrownBy(() -> service.startSyncAll(ADMIN, SyncMode.FILL)).isInstanceOf(ConflictException.class);
    }

    private MetadataSyncJobResponse waitForEnd() throws InterruptedException {
        for (int i = 0; i < 100; i++) {
            MetadataSyncJobResponse status = service.status(ADMIN);
            if (status.state() == SyncState.DONE) {
                return status;
            }
            Thread.sleep(50);
        }
        throw new AssertionError("Resynchronisation still running");
    }

    private static Optional<MetadataMerger.Merged> merged() {
        return Optional.of(new MetadataMerger.Merged(LookupSource.BNF, FOUND, List.of(FOUND.coverUrl())));
    }

    private static Book book(String title, String coverKey) {
        Book book = new Book(1L, 7L);
        book.setIsbn13(ISBN);
        book.setTitle(title);
        book.setCoverKey(coverKey);
        return book;
    }
}
