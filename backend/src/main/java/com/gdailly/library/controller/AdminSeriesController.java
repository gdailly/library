package com.gdailly.library.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.SeriesSyncService;
import com.gdailly.library.dto.SeriesDetailResponse;
import com.gdailly.library.dto.SeriesSyncJobResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Forced listing of the volumes of the series from the BnF, reserved to the administrator (403 otherwise). */
@RestController
@Tag(name = "Admin", description = "Administration des métadonnées (propriétaire)")
@RequestMapping("/api/admin/series")
class AdminSeriesController {

    private final SeriesSyncService sync;

    AdminSeriesController(SeriesSyncService sync) {
        this.sync = sync;
    }

    /** Starts listing again the volumes of every series in the background; 409 if one is running. */
    @PostMapping("/sync")
    @ResponseStatus(HttpStatus.ACCEPTED)
    SeriesSyncJobResponse startSeriesSync(CurrentUser user) {
        return sync.startAll(user);
    }

    @GetMapping("/sync")
    SeriesSyncJobResponse getSeriesSync(CurrentUser user) {
        return sync.status(user);
    }

    /** Lists again the volumes of one series now and returns it volume by volume; 503 if the BnF fails. */
    @PostMapping("/sync-one")
    SeriesDetailResponse syncOneSeries(CurrentUser user, @RequestParam @NotBlank @Size(max = 300) String name) {
        return sync.syncOne(user, name);
    }
}
