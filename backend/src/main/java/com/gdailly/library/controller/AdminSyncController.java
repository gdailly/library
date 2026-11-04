package com.gdailly.library.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.SyncHistoryService;
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.dto.SyncRunItemResponse;
import com.gdailly.library.dto.SyncRunResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.constraints.Min;

/** History of the synchronisations (30 days), reserved to the administrator (403 otherwise). */
@RestController
@Tag(name = "Admin", description = "Administration des métadonnées (propriétaire)")
@RequestMapping("/api/admin/syncs")
class AdminSyncController {

    private final SyncHistoryService history;

    AdminSyncController(SyncHistoryService history) {
        this.history = history;
    }

    /** The synchronisations of the last 30 days, most recent first, 20 per page. */
    @GetMapping
    PageResponse<SyncRunResponse> listSyncRuns(CurrentUser user, @RequestParam(defaultValue = "0") @Min(0) int page) {
        return history.list(user, page);
    }

    /** One synchronisation and its counters, to follow it while it runs. */
    @GetMapping("/{id}")
    SyncRunResponse getSyncRun(CurrentUser user, @PathVariable Long id) {
        return history.get(user, id);
    }

    /** What the synchronisation did with each book or series, most recent first, 50 per page. */
    @GetMapping("/{id}/items")
    PageResponse<SyncRunItemResponse> listSyncRunItems(CurrentUser user, @PathVariable Long id,
            @RequestParam(defaultValue = "false") boolean problemsOnly,
            @RequestParam(defaultValue = "0") @Min(0) int page) {
        return history.items(user, id, problemsOnly, page);
    }
}
