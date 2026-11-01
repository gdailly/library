package com.gdailly.library.dto;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

/**
 * Copies some fields of one source into the book: title, subtitle, authors, publisher, year, pages, language,
 * summary, cover.
 */
public record ApplyMetadataRequest(@NotNull MetadataSource source, @NotEmpty List<String> fields) {
}
