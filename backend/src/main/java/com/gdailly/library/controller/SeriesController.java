package com.gdailly.library.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.BookService;
import com.gdailly.library.business.SeriesService;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.SeriesDetailResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@RestController
@Tag(name = "Series", description = "Séries : albums présents, envies et tomes manquants")
@RequestMapping("/api/series")
class SeriesController {

    private final SeriesService series;
    private final BookService books;

    SeriesController(SeriesService series, BookService books) {
        this.series = series;
        this.books = books;
    }

    /** Every series of the library, by name; {@code q} keeps those whose name contains it. */
    @GetMapping
    List<SeriesResponse> listSeries(CurrentUser user, @RequestParam(required = false) String q) {
        return series.list(user, q);
    }

    /** One series volume by volume, including the volumes the library does not hold; 404 if it has no book of it. */
    @GetMapping("/volumes")
    SeriesDetailResponse getSeriesVolumes(CurrentUser user, @RequestParam @NotBlank @Size(max = 300) String name) {
        return series.detail(user, name);
    }

    /** The books of one series, by volume number. */
    @GetMapping("/books")
    List<BookResponse> listSeriesBooks(CurrentUser user, @RequestParam @NotBlank @Size(max = 300) String name) {
        return books.seriesBooks(user, name);
    }
}
