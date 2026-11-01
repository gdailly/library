package com.gdailly.library.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.MetadataSyncService;
import com.gdailly.library.dto.BookSyncResponse;
import com.gdailly.library.dto.CacheClearResponse;
import com.gdailly.library.dto.CacheScope;
import com.gdailly.library.dto.MetadataAdminResponse;
import com.gdailly.library.dto.MetadataSyncJobResponse;
import com.gdailly.library.dto.SyncMode;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

/** Metadata administration, reserved to the owners of the library (403 otherwise). */
@RestController
@Tag(name = "Admin", description = "Administration des métadonnées (propriétaire)")
@RequestMapping("/api/admin/metadata")
class AdminController {

    private final MetadataSyncService sync;

    AdminController(MetadataSyncService sync) {
        this.sync = sync;
    }

    @GetMapping
    MetadataAdminResponse getMetadataAdmin(CurrentUser user) {
        return sync.overview(user);
    }

    /** Starts resynchronising every book with an ISBN in the background (empty fields only); 409 if one is running. */
    @PostMapping("/sync")
    @ResponseStatus(HttpStatus.ACCEPTED)
    MetadataSyncJobResponse startMetadataSync(CurrentUser user) {
        return sync.startSyncAll(user);
    }

    @GetMapping("/sync")
    MetadataSyncJobResponse getMetadataSync(CurrentUser user) {
        return sync.status(user);
    }

    /**
     * Resynchronises one book now (FILL when no mode is given); 400 when it has no ISBN, 503 when a source could not
     * be reached. Enum parameters have no declared default: the generated Dart client cannot express one.
     */
    @PostMapping("/books/{id}/sync")
    BookSyncResponse syncBookMetadata(CurrentUser user, @PathVariable Long id,
            @RequestParam(required = false) SyncMode mode) {
        return sync.syncBook(user, id, mode == null ? SyncMode.FILL : mode);
    }

    /** Deletes the "not found" entries of the ISBN cache, or all its entries with {@code scope=ALL}. */
    @DeleteMapping("/cache")
    CacheClearResponse clearIsbnCache(CurrentUser user, @RequestParam(required = false) CacheScope scope) {
        return sync.clearCache(user, scope == null ? CacheScope.NOT_FOUND : scope);
    }
}
