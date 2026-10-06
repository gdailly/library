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

import java.nio.file.Path;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.util.unit.DataSize;
import org.springframework.web.client.RestClientException;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.client.CoverDownloader;
import com.gdailly.library.client.GoogleBooksClient;
import com.gdailly.library.client.OpenLibraryClient;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.CoverSize;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CoverUrlSigner;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.storage.CoverStore;

class CoverServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "alice@example.com", 1L, Role.MEMBER);
    private static final String ISBN = "9782070612758";
    private static final String KEY = "c".repeat(64);
    private static final String IMAGE_URL = "https://covers.example.com/1.jpg";

    private final BookRepository books = mock(BookRepository.class);
    private final IsbnLookupRepository isbnCache = mock(IsbnLookupRepository.class);
    private final CoverStore store = mock(CoverStore.class);
    private final CoverDownloader downloader = mock(CoverDownloader.class);
    private final OpenLibraryClient openLibrary = mock(OpenLibraryClient.class);
    private final GoogleBooksClient googleBooks = mock(GoogleBooksClient.class);
    private final LivreProperties properties = new LivreProperties(null, null, null, null,
            new LivreProperties.Covers(null, "unit-test-secret-0123", null, DataSize.ofBytes(10)));
    private final CoverUrlSigner signer =
            new CoverUrlSigner(properties, Clock.fixed(Instant.parse("2026-10-06T08:00:00Z"), ZoneOffset.UTC));
    private final CoverService service = new CoverService(books, isbnCache, store, signer, downloader, openLibrary,
            googleBooks, properties);

    @Test
    void reusesCoverAlreadyDownloadedForTheIsbn() {
        IsbnLookup entry = new IsbnLookup(ISBN, LookupSource.OPEN_LIBRARY, "ol", Instant.now());
        entry.setCoverKey(KEY);
        when(isbnCache.findById(ISBN)).thenReturn(Optional.of(entry));

        assertThat(service.importFromIsbn(ISBN)).contains(KEY);
        verifyNoInteractions(downloader, store);
    }

    @Test
    void downloadsCoverOnceAndRemembersIt() {
        IsbnLookup entry = new IsbnLookup(ISBN, LookupSource.GOOGLE_BOOKS, "gb", Instant.now());
        when(isbnCache.findById(ISBN)).thenReturn(Optional.of(entry));
        when(googleBooks.parse(ISBN, "gb")).thenReturn(Optional.of(metadataWithCover(IMAGE_URL)));
        when(downloader.download(IMAGE_URL)).thenReturn(Optional.of(new byte[] {1, 2, 3}));
        when(store.store(any())).thenReturn(KEY);

        assertThat(service.importFromIsbn(ISBN)).contains(KEY);
        assertThat(entry.getCoverKey()).isEqualTo(KEY);
        verify(isbnCache).save(entry);
    }

    @Test
    void hasNoCoverForUnknownOrNotFoundIsbn() {
        when(isbnCache.findById(ISBN)).thenReturn(Optional.empty());
        assertThat(service.importFromIsbn(ISBN)).isEmpty();

        when(isbnCache.findById(ISBN)).thenReturn(Optional.of(new IsbnLookup(ISBN, LookupSource.NOT_FOUND, null, Instant.now())));
        assertThat(service.importFromIsbn(ISBN)).isEmpty();
        verifyNoInteractions(downloader);
    }

    @Test
    void hasNoCoverWhenMetadataOffersNone() {
        when(isbnCache.findById(ISBN)).thenReturn(Optional.of(new IsbnLookup(ISBN, LookupSource.OPEN_LIBRARY, "ol", Instant.now())));
        when(openLibrary.parse(ISBN, "ol")).thenReturn(Optional.of(metadataWithCover(null)));

        assertThat(service.importFromIsbn(ISBN)).isEmpty();
        verifyNoInteractions(downloader);
    }

    @Test
    void swallowsDownloadFailures() {
        IsbnLookup entry = new IsbnLookup(ISBN, LookupSource.OPEN_LIBRARY, "ol", Instant.now());
        when(isbnCache.findById(ISBN)).thenReturn(Optional.of(entry));
        when(openLibrary.parse(ISBN, "ol")).thenReturn(Optional.of(metadataWithCover(IMAGE_URL)));
        when(downloader.download(anyString())).thenThrow(new RestClientException("timeout"));

        assertThat(service.importFromIsbn(ISBN)).isEmpty();
        verify(isbnCache, never()).save(any());
    }

    @Test
    void uploadStoresImageAndReturnsSignedUrls() {
        Book book = book(5L);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(store.store(any())).thenReturn(KEY);

        CoverResponse urls = service.upload(USER, 5L, new byte[] {1, 2});

        assertThat(book.getCoverKey()).isEqualTo(KEY);
        assertThat(urls.thumbUrl()).startsWith("/api/books/5/cover?size=thumb&key=" + KEY + "&expires=");
        assertThat(urls.mediumUrl()).contains("size=medium");
    }

    @Test
    void uploadRefusesEmptyTooLargeOrUnreadableImages() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book(5L)));
        when(store.store(any())).thenThrow(new IllegalArgumentException("not an image"));

        assertThatThrownBy(() -> service.upload(USER, 5L, new byte[0])).isInstanceOf(BadRequestException.class);
        assertThatThrownBy(() -> service.upload(USER, 5L, new byte[11])).isInstanceOf(BadRequestException.class);
        assertThatThrownBy(() -> service.upload(USER, 5L, new byte[] {1})).isInstanceOf(BadRequestException.class);
    }

    @Test
    void uploadAcceptsImageOfExactlyTheMaximumSize() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book(5L)));
        when(store.store(any())).thenReturn(KEY);

        assertThat(service.upload(USER, 5L, new byte[10])).isNotNull();
    }

    @Test
    void opensOnlyValidlySignedFiles() {
        Book book = book(5L);
        book.setCoverKey(KEY);
        CoverResponse urls = service.urls(book);
        String query = urls.mediumUrl().substring(urls.mediumUrl().indexOf("expires="));
        long expires = Long.parseLong(query.substring("expires=".length(), query.indexOf('&')));
        String sig = query.substring(query.indexOf("sig=") + 4);
        when(store.find(KEY, CoverStore.Variant.MEDIUM)).thenReturn(Optional.of(Path.of("medium.webp")));

        CoverService.CoverFile file = service.open(5L, CoverSize.MEDIUM, KEY, expires, sig);

        assertThat(file.contentType()).isEqualTo("image/webp");
        assertThat(file.etag()).isEqualTo("\"" + KEY + "-medium\"");
        assertThatThrownBy(() -> service.open(6L, CoverSize.MEDIUM, KEY, expires, sig)).isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.open(5L, CoverSize.THUMB, KEY, expires, sig)).isInstanceOf(NotFoundException.class);
    }

    @Test
    void hasNoUrlsWithoutCover() {
        assertThat(service.urls(book(5L))).isNull();
    }

    private static Book book(long id) {
        Book book = new Book(1L, 7L);
        ReflectionTestUtils.setField(book, "id", id);
        return book;
    }

    private static BookMetadata metadataWithCover(String coverUrl) {
        return new BookMetadata("Titre", null, null, null, null, null, null, null, coverUrl);
    }
}
