package com.gdailly.library.dto;

import java.time.Instant;
import java.util.List;

import org.jspecify.annotations.Nullable;

/** A line of the metadata administration list; see {@link BookMetadataResponse} for the fields. */
public record BookMetadataSummary(
        Long id,
        String title,
        @Nullable String authors,
        String isbn13,
        boolean hasCover,
        List<MetadataSource> sources,
        @Nullable Instant fetchedAt,
        boolean notFound,
        List<String> differences) {
}
