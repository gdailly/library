package com.gdailly.library.dto;

import org.jspecify.annotations.Nullable;

/**
 * Metadata used to pre-fill the add-book form. {@code existingBookId} is set when the book is already in the library.
 * {@code coverUrl} points to the external source's image and is not meant to be displayed as is.
 */
public record IsbnLookupResponse(
        String isbn13,
        MetadataSource source,
        @Nullable Long existingBookId,
        String title,
        @Nullable String subtitle,
        @Nullable String authors,
        @Nullable String publisher,
        @Nullable Integer year,
        @Nullable Integer pages,
        @Nullable String language,
        @Nullable String summary,
        @Nullable String coverUrl) {
}
