package com.gdailly.library.business;

import java.nio.file.Path;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CoverUrlSigner;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.storage.CoverStore;

/** Covers are downloaded or uploaded once, stored by content hash and served through signed URLs. */
@Service
public class CoverService {

    private static final Logger log = LoggerFactory.getLogger(CoverService.class);

    private final BookRepository books;
    private final IsbnLookupRepository isbnCache;
    private final CoverStore store;
    private final CoverUrlSigner signer;
    private final CoverDownloader downloader;
    private final OpenLibraryClient openLibrary;
    private final GoogleBooksClient googleBooks;
    private final long maxBytes;

    CoverService(BookRepository books, IsbnLookupRepository isbnCache, CoverStore store, CoverUrlSigner signer,
            CoverDownloader downloader, OpenLibraryClient openLibrary, GoogleBooksClient googleBooks,
            LivreProperties properties) {
        this.books = books;
        this.isbnCache = isbnCache;
        this.store = store;
        this.signer = signer;
        this.downloader = downloader;
        this.openLibrary = openLibrary;
        this.googleBooks = googleBooks;
        this.maxBytes = properties.covers().maxSize().toBytes();
    }

    /** A cover file ready to be sent; {@code etag} identifies its content. */
    public record CoverFile(Path path, String contentType, String etag) {
    }

    /** Signed URLs of a book's cover, or null when it has none. */
    public CoverResponse urls(Book book) {
        if (book.getCoverKey() == null || book.getId() == null) {
            return null;
        }
        CoverUrlSigner.SignedCover signed = signer.sign(book.getId(), book.getCoverKey());
        return new CoverResponse(url(book, CoverSize.THUMB, signed), url(book, CoverSize.MEDIUM, signed));
    }

    /** Serves a file named by a signed URL; the database is not read. */
    public CoverFile open(long bookId, CoverSize size, String key, long expires, String signature) {
        if (!signer.isValid(bookId, key, expires, signature)) {
            throw new ForbiddenException("Lien de couverture invalide ou expiré.");
        }
        CoverStore.Variant variant = size == CoverSize.MEDIUM ? CoverStore.Variant.MEDIUM : CoverStore.Variant.THUMB;
        Path path = store.find(key, variant).orElseThrow(NotFoundException::new);
        return new CoverFile(path, variant.contentType(), "\"" + key + "-" + size.queryValue() + "\"");
    }

    @Transactional
    public CoverResponse upload(CurrentUser user, Long bookId, byte[] image) {
        Book book = books.findByIdAndLibraryId(bookId, user.libraryId()).orElseThrow(NotFoundException::new);
        if (image.length == 0 || image.length > maxBytes) {
            throw new BadRequestException("Image vide ou trop volumineuse.");
        }
        try {
            book.setCoverKey(store.store(image));
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Format d'image non reconnu (JPEG, PNG ou WebP).");
        }
        return urls(book);
    }

    @Transactional
    public void remove(CurrentUser user, Long bookId) {
        // Files stay: other books or the ISBN cache may share the same image.
        books.findByIdAndLibraryId(bookId, user.libraryId()).orElseThrow(NotFoundException::new).setCoverKey(null);
    }

    /**
     * Cover of a cached ISBN lookup, downloaded on first use and shared afterwards.
     * Empty when the ISBN was never looked up, has no cover, or the download fails: a book is never refused for that.
     */
    public Optional<String> importFromIsbn(String isbn13) {
        Optional<IsbnLookup> entry = isbnCache.findById(isbn13);
        if (entry.isEmpty() || entry.get().getSource() == LookupSource.NOT_FOUND) {
            return Optional.empty();
        }
        IsbnLookup lookup = entry.get();
        if (lookup.getCoverKey() != null) {
            return Optional.of(lookup.getCoverKey());
        }
        Optional<BookMetadata> metadata = lookup.getSource() == LookupSource.GOOGLE_BOOKS
                ? googleBooks.parse(isbn13, lookup.getPayload())
                : openLibrary.parse(isbn13, lookup.getPayload());
        String coverUrl = metadata.map(BookMetadata::coverUrl).orElse(null);
        if (coverUrl == null) {
            return Optional.empty();
        }
        try {
            Optional<String> key = downloader.download(coverUrl).map(store::store);
            key.ifPresent(k -> {
                lookup.setCoverKey(k);
                isbnCache.save(lookup);
            });
            return key;
        } catch (RuntimeException e) {
            log.warn("Cover download for ISBN {} failed: {}", isbn13, e.toString());
            return Optional.empty();
        }
    }

    private static String url(Book book, CoverSize size, CoverUrlSigner.SignedCover signed) {
        return "/api/books/" + book.getId() + "/cover?size=" + size.queryValue() + "&key=" + book.getCoverKey()
                + "&expires=" + signed.expires() + "&sig=" + signed.signature();
    }
}
