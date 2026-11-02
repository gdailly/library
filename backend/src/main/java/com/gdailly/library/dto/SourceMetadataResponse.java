package com.gdailly.library.dto;

import org.jspecify.annotations.Nullable;

/**
 * What one source (or the merge of all, {@code source} = null) says about a book's ISBN, as stored in the cache.
 * {@code coverUrl} is the source's own image.
 */
public record SourceMetadataResponse(
        @Nullable MetadataSource source,
        String title,
        @Nullable String subtitle,
        @Nullable String series,
        @Nullable Integer seriesNumber,
        @Nullable String authors,
        @Nullable String publisher,
        @Nullable Integer year,
        @Nullable Integer pages,
        @Nullable String language,
        @Nullable String summary,
        @Nullable String coverUrl) {
}
