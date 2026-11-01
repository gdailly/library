package com.gdailly.library.dto;

import java.time.Instant;
import java.util.List;

import org.jspecify.annotations.Nullable;

/**
 * A book beside the answers of the sources for its ISBN. {@code sources} lists only the sources that know it;
 * {@code merged} is what a resynchronisation would use. {@code differences} names the book fields (as in
 * {@link BookResponse}, plus "cover" when the book has none but a source has one) where a source disagrees.
 * {@code fetchedAt} is null when the ISBN was never looked up; {@code notFound} when no source knew it.
 */
public record BookMetadataResponse(
        BookResponse book,
        @Nullable Instant fetchedAt,
        boolean notFound,
        List<SourceMetadataResponse> sources,
        @Nullable SourceMetadataResponse merged,
        List<String> differences) {
}
