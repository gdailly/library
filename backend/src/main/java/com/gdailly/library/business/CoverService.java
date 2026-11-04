package com.gdailly.library.business;

import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.client.CoverDownloader;
import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.CoverSize;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CoverUrlSigner;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.storage.CoverStore;

/** Covers are downloaded or uploaded once, stored by content hash and served through signed URLs. */
@Service
public class CoverService {

    private static final Logger log = LoggerFactory.getLogger(CoverService.class);

    private final LibraryBookRepository entries;
    private final IsbnLookupRepository isbnCache;
    private final CoverStore store;
    private final CoverUrlSigner signer;
    private final CoverDownloader downloader;
    private final MetadataSources sources;
    private final long maxBytes;

    CoverService(LibraryBookRepository entries, IsbnLookupRepository isbnCache, CoverStore store, CoverUrlSigner signer,
            CoverDownloader downloader, MetadataSources sources, LivreProperties properties) {
        this.entries = entries;
        this.isbnCache = isbnCache;
        this.store = store;
        this.signer = signer;
        this.downloader = downloader;
        this.sources = sources;
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
        Book book = entries.findByLibraryIdAndBookId(user.libraryId(), bookId).orElseThrow(NotFoundException::new).getBook();
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
        entries.findByLibraryIdAndBookId(user.libraryId(), bookId).orElseThrow(NotFoundException::new).getBook()
                .setCoverKey(null);
    }

    /**
     * Cover of a cached ISBN lookup, downloaded on first use and shared afterwards. The images offered by the sources
     * are tried best first, so that a slow or broken one does not leave the book without a cover.
     * Empty when the ISBN was never looked up, has no cover, or every download fails: a book is never refused for that.
     */
    public Optional<String> importFromIsbn(String isbn13) {
        Optional<IsbnLookup> entry = isbnCache.findById(isbn13);
        if (entry.isEmpty()) {
            return Optional.empty();
        }
        IsbnLookup lookup = entry.get();
        if (lookup.getCoverKey() != null) {
            return Optional.of(lookup.getCoverKey());
        }
        List<String> coverUrls = MetadataMerger.merge(sources.decode(lookup))
                .map(MetadataMerger.Merged::coverUrls)
                .orElse(List.of());
        for (String coverUrl : coverUrls) {
            try {
                Optional<String> key = downloader.download(coverUrl).map(store::store);
                if (key.isPresent()) {
                    lookup.setCoverKey(key.get());
                    isbnCache.save(lookup);
                    return key;
                }
            } catch (RuntimeException e) {
                log.warn("Cover download for ISBN {} from {} failed: {}", isbn13, coverUrl, e.toString());
            }
        }
        return Optional.empty();
    }

    /** A cover downloaded from one source's image; empty when the download fails or is not an image. */
    public Optional<String> importFromUrl(String coverUrl) {
        try {
            return downloader.download(coverUrl).map(store::store);
        } catch (RuntimeException e) {
            log.warn("Cover download from {} failed: {}", coverUrl, e.toString());
            return Optional.empty();
        }
    }

    private static String url(Book book, CoverSize size, CoverUrlSigner.SignedCover signed) {
        return "/api/books/" + book.getId() + "/cover?size=" + size.queryValue() + "&key=" + book.getCoverKey()
                + "&expires=" + signed.expires() + "&sig=" + signed.signature();
    }
}
