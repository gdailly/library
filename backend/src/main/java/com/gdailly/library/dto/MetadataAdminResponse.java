package com.gdailly.library.dto;

/**
 * Administration page: the library's books, the shared ISBN cache ({@code cachedNotFound} of its
 * {@code cachedIsbns} entries remember an ISBN that no source knew) and the full resynchronisation.
 */
public record MetadataAdminResponse(
        long books,
        long booksWithIsbn,
        long cachedIsbns,
        long cachedNotFound,
        MetadataSyncJobResponse job) {
}
