package com.gdailly.library.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.MetadataInspectionService;
import com.gdailly.library.business.MetadataSyncService;
import com.gdailly.library.dto.ApplyMetadataRequest;
import com.gdailly.library.dto.BookMetadataResponse;
import com.gdailly.library.dto.BookMetadataSummary;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.dto.BookSyncResponse;
import com.gdailly.library.dto.CacheClearResponse;
import com.gdailly.library.dto.CacheScope;
import com.gdailly.library.dto.MetadataAdminResponse;
import com.gdailly.library.dto.MetadataSyncJobResponse;
import com.gdailly.library.dto.SyncMode;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;

/** Metadata administration, reserved to the administrator of the application, BOOTSTRAP_OWNER_EMAIL (403 otherwise). */
@RestController
@Tag(name = "Admin", description = "Administration des métadonnées (propriétaire)")
@RequestMapping("/api/admin/metadata")
class AdminController {

    private final MetadataSyncService sync;
    private final MetadataInspectionService inspection;

    AdminController(MetadataSyncService sync, MetadataInspectionService inspection) {
        this.sync = sync;
        this.inspection = inspection;
    }

    @GetMapping
    MetadataAdminResponse getMetadataAdmin(CurrentUser user) {
        return sync.overview(user);
    }

    /**
     * Starts resynchronising every book with an ISBN in the background: FILL (no mode) completes empty fields only,
     * FETCH only refreshes the answers of the sources; 409 if one is running.
     */
    @PostMapping("/sync")
    @ResponseStatus(HttpStatus.ACCEPTED)
    MetadataSyncJobResponse startMetadataSync(CurrentUser user, @RequestParam(required = false) SyncMode mode) {
        return sync.startSyncAll(user, mode == null ? SyncMode.FILL : mode);
    }

    @GetMapping("/sync")
    MetadataSyncJobResponse getMetadataSync(CurrentUser user) {
        return sync.status(user);
    }

    /**
     * Resynchronises one book now (FILL when no mode is given), with every source or with {@code source} only;
     * 400 when it has no ISBN, 503 when a source could not be reached.
     * Enum parameters have no declared default: the generated Dart client cannot express one.
     */
    @PostMapping("/books/{id}/sync")
    BookSyncResponse syncBookMetadata(CurrentUser user, @PathVariable Long id,
            @RequestParam(required = false) SyncMode mode, @RequestParam(required = false) MetadataSource source) {
        if (source == MetadataSource.LIBRARY) {
            throw new BadRequestException("Choisis une source externe.");
        }
        return sync.syncBook(user, id, mode == null ? SyncMode.FILL : mode,
                source == null ? null : LookupSource.valueOf(source.name()));
    }

    /** Books with an ISBN and how their sources compare, 50 per page. */
    @GetMapping("/books")
    PageResponse<BookMetadataSummary> listBookMetadata(CurrentUser user,
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "false") boolean onlyDifferences,
            @RequestParam(defaultValue = "0") @Min(0) int page) {
        return inspection.list(user, q, onlyDifferences, page);
    }

    /** A book beside the stored answer of each source. */
    @GetMapping("/books/{id}")
    BookMetadataResponse getBookMetadata(CurrentUser user, @PathVariable Long id) {
        return inspection.get(user, id);
    }

    /** Copies chosen fields of one source into the book; 409 when that source has no answer stored. */
    @PostMapping("/books/{id}/apply")
    BookMetadataResponse applyBookMetadata(CurrentUser user, @PathVariable Long id,
            @Valid @RequestBody ApplyMetadataRequest request) {
        return inspection.apply(user, id, request);
    }

    /** Deletes the "not found" entries of the ISBN cache, or all its entries with {@code scope=ALL}. */
    @DeleteMapping("/cache")
    CacheClearResponse clearIsbnCache(CurrentUser user, @RequestParam(required = false) CacheScope scope) {
        return sync.clearCache(user, scope == null ? CacheScope.NOT_FOUND : scope);
    }
}
