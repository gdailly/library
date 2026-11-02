package com.gdailly.library.client;

import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Book metadata as understood from an external API; any field may be null except {@code title}.
 * {@code seriesNumber} is the volume number within {@code series}.
 */
public record BookMetadata(
        String title,
        String subtitle,
        String authors,
        String publisher,
        Integer year,
        Integer pages,
        String language,
        String summary,
        String coverUrl,
        String series,
        Integer seriesNumber) {

    private static final Pattern YEAR = Pattern.compile("\\b(\\d{4})\\b");
    private static final Pattern NUMBER = Pattern.compile("(\\d{1,4})");

    /** Metadata of a book outside any series, or from a source that does not tell. */
    public BookMetadata(String title, String subtitle, String authors, String publisher, Integer year, Integer pages,
            String language, String summary, String coverUrl) {
        this(title, subtitle, authors, publisher, year, pages, language, summary, coverUrl, null, null);
    }

    /** Volume number in free text such as "3", "T. 12" or "40" ; null for "HS" or none. */
    static Integer parseSeriesNumber(String volume) {
        if (volume == null) {
            return null;
        }
        Matcher matcher = NUMBER.matcher(volume);
        return matcher.find() ? positive(Integer.parseInt(matcher.group(1))) : null;
    }

    /** A series title without the final punctuation catalogues add: "Une aventure d'Astérix." → "Une aventure d'Astérix". */
    static String seriesTitle(String value) {
        String text = text(value);
        if (text == null) {
            return null;
        }
        return text(text.replaceAll("[\\s.,;:/]+$", ""));
    }

    /** First four-digit year in free text such as "March 1999" or "2003-05-01". */
    static Integer parseYear(String date) {
        if (date == null) {
            return null;
        }
        Matcher matcher = YEAR.matcher(date);
        return matcher.find() ? Integer.valueOf(matcher.group(1)) : null;
    }

    static String text(String value) {
        return Optional.ofNullable(value).map(String::trim).filter(s -> !s.isEmpty()).orElse(null);
    }

    static Integer positive(int value) {
        return value > 0 ? value : null;
    }
}
