package com.gdailly.library.business;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.entity.LookupSource;

/**
 * Combines the answers of several metadata sources field by field: each field takes the first non-empty value
 * in its own order of preference (see docs/conception/decisions.md).
 */
final class MetadataMerger {

    /** The BnF catalogue is the reference for French books; Open Library and Google Books come next. */
    static final List<LookupSource> BIBLIOGRAPHIC = List.of(LookupSource.BNF, LookupSource.OPEN_LIBRARY, LookupSource.GOOGLE_BOOKS);
    /** Open Library counts the pages of the edition; the BnF often gives "1 vol." only. */
    static final List<LookupSource> PAGES = List.of(LookupSource.OPEN_LIBRARY, LookupSource.BNF, LookupSource.GOOGLE_BOOKS);
    /** Only Google Books has publisher summaries; the BnF rarely does. */
    static final List<LookupSource> DESCRIPTIVE = List.of(LookupSource.GOOGLE_BOOKS, LookupSource.BNF, LookupSource.OPEN_LIBRARY);
    /** Series come with their volume number from the BnF; Open Library only names them. */
    static final List<LookupSource> SERIES = List.of(LookupSource.BNF, LookupSource.OPEN_LIBRARY, LookupSource.GOOGLE_BOOKS);
    /** Google Books images are the largest; Open Library covers are served slowly by archive.org. */
    static final List<LookupSource> COVERS = List.of(LookupSource.GOOGLE_BOOKS, LookupSource.OPEN_LIBRARY, LookupSource.BNF);

    private MetadataMerger() {
    }

    /** Merged metadata, the source of its title, and every cover URL offered, best first. */
    record Merged(LookupSource source, BookMetadata metadata, List<String> coverUrls) {
    }

    static Optional<Merged> merge(Map<LookupSource, BookMetadata> answers) {
        Optional<LookupSource> titleSource = BIBLIOGRAPHIC.stream().filter(answers::containsKey).findFirst();
        if (titleSource.isEmpty()) {
            return Optional.empty();
        }
        List<String> covers = new ArrayList<>();
        for (LookupSource source : COVERS) {
            BookMetadata answer = answers.get(source);
            if (answer != null && answer.coverUrl() != null && !covers.contains(answer.coverUrl())) {
                covers.add(answer.coverUrl());
            }
        }
        // The series and its volume number are taken together, from the first source that names the series.
        Optional<BookMetadata> series = SERIES.stream()
                .map(answers::get)
                .filter(answer -> answer != null && answer.series() != null)
                .findFirst();
        BookMetadata merged = new BookMetadata(
                answers.get(titleSource.get()).title(),
                first(answers, BIBLIOGRAPHIC, BookMetadata::subtitle),
                first(answers, BIBLIOGRAPHIC, BookMetadata::authors),
                first(answers, BIBLIOGRAPHIC, BookMetadata::publisher),
                first(answers, BIBLIOGRAPHIC, BookMetadata::year),
                first(answers, PAGES, BookMetadata::pages),
                first(answers, DESCRIPTIVE, BookMetadata::language),
                first(answers, DESCRIPTIVE, BookMetadata::summary),
                covers.isEmpty() ? null : covers.getFirst(),
                series.map(BookMetadata::series).orElse(null),
                series.map(BookMetadata::seriesNumber).orElse(null));
        return Optional.of(new Merged(titleSource.get(), merged, List.copyOf(covers)));
    }

    private static <T> T first(Map<LookupSource, BookMetadata> answers, List<LookupSource> order,
            Function<BookMetadata, T> field) {
        return order.stream()
                .map(answers::get)
                .filter(Objects::nonNull)
                .map(field)
                .filter(Objects::nonNull)
                .findFirst()
                .orElse(null);
    }
}
