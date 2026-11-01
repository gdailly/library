package com.gdailly.library.dto;

import java.util.List;

/**
 * A book after its metadata resynchronisation. {@code changedFields} names the changed properties, as in
 * {@link BookResponse} (title, subtitle, authors, publisher, year, pages, language, summary, cover).
 */
public record BookSyncResponse(SyncOutcome outcome, List<String> changedFields, BookResponse book) {
}
