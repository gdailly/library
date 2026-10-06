package com.gdailly.library.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.IsbnLookupService;
import com.gdailly.library.dto.IsbnLookupResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@Tag(name = "Lookup", description = "Recherche de métadonnées")
@RequestMapping("/api/lookup")
class LookupController {

    private final IsbnLookupService isbnLookup;

    LookupController(IsbnLookupService isbnLookup) {
        this.isbnLookup = isbnLookup;
    }

    /** 404 when no source knows the ISBN, 503 when a source could not be reached. */
    @GetMapping("/isbn/{isbn}")
    IsbnLookupResponse lookupIsbn(CurrentUser user, @PathVariable String isbn) {
        return isbnLookup.lookup(user, isbn);
    }
}
