package com.gdailly.library.dto;

/**
 * Metadata used to pre-fill the add-book form. {@code existingBookId} is set when the book is already in the library.
 * {@code coverUrl} points to the external source's image and is not meant to be displayed as is.
 */
public record IsbnLookupResponse(
        String isbn13,
        MetadataSource source,
        Long existingBookId,
        String title,
        String subtitle,
        String authors,
        String publisher,
        Integer year,
        Integer pages,
        String language,
        String summary,
        String coverUrl) {
}
