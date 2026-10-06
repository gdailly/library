package com.gdailly.library.controller;

import java.io.IOException;
import java.time.Duration;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.MultipartFile;

import com.gdailly.library.business.BookService;
import com.gdailly.library.business.CoverService;
import com.gdailly.library.business.ReadingService;
import com.gdailly.library.dto.BookRequest;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.CoverSize;
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.dto.ReadingRequest;
import com.gdailly.library.dto.ReadingResponse;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

@RestController
@Tag(name = "Books", description = "Livres, couvertures et suivi de lecture")
@RequestMapping("/api/books")
class BookController {

    private final BookService books;
    private final ReadingService readings;
    private final CoverService covers;

    BookController(BookService books, ReadingService readings, CoverService covers) {
        this.books = books;
        this.readings = readings;
        this.covers = covers;
    }

    /** {@code status} and {@code minRating} filter on the caller's own readings. */
    @GetMapping
    PageResponse<BookResponse> listBooks(CurrentUser user,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Boolean owned,
            @RequestParam(required = false) Long category,
            @RequestParam(required = false) ReadingStatus status,
            @RequestParam(required = false) @Min(1) @Max(5) Integer minRating,
            @RequestParam(defaultValue = "0") @Min(0) int page) {
        return books.search(user, new BookService.SearchCriteria(q, owned, category, status, minRating), page);
    }

    /** Public: authorised by the signature of URLs returned in {@link BookResponse#cover()}, not by the token. */
    @GetMapping("/{id}/cover")
    ResponseEntity<Resource> getCover(@PathVariable long id,
            @RequestParam(defaultValue = "thumb") String size,
            @RequestParam String key,
            @RequestParam long expires,
            @RequestParam String sig,
            WebRequest request) {
        CoverSize coverSize = "medium".equalsIgnoreCase(size) ? CoverSize.MEDIUM : CoverSize.THUMB;
        CoverService.CoverFile file = covers.open(id, coverSize, key, expires, sig);
        if (request.checkNotModified(file.etag())) {
            return null;
        }
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(file.contentType()))
                .cacheControl(CacheControl.maxAge(Duration.ofDays(1)).cachePrivate())
                .eTag(file.etag())
                .body(new FileSystemResource(file.path()));
    }

    /** Replaces the cover with an uploaded image (JPEG, PNG or WebP, 5 MB at most). */
    @PutMapping(path = "/{id}/cover", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    CoverResponse uploadCover(CurrentUser user, @PathVariable Long id, @RequestPart("file") MultipartFile file)
            throws IOException {
        return covers.upload(user, id, file.getBytes());
    }

    @DeleteMapping("/{id}/cover")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deleteCover(CurrentUser user, @PathVariable Long id) {
        covers.remove(user, id);
    }

    @PutMapping("/{id}/reading")
    ReadingResponse saveMyReading(CurrentUser user, @PathVariable Long id, @Valid @RequestBody ReadingRequest request) {
        return readings.save(user, id, request);
    }

    @GetMapping("/{id}")
    BookResponse getBook(CurrentUser user, @PathVariable Long id) {
        return books.get(user, id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    BookResponse createBook(CurrentUser user, @Valid @RequestBody BookRequest request) {
        return books.create(user, request);
    }

    @PutMapping("/{id}")
    BookResponse updateBook(CurrentUser user, @PathVariable Long id, @Valid @RequestBody BookRequest request) {
        return books.update(user, id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deleteBook(CurrentUser user, @PathVariable Long id) {
        books.delete(user, id);
    }
}
