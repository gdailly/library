package com.gdailly.library.client;

import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Book metadata as understood from an external API; any field may be null except {@code title}. */
public record BookMetadata(
        String title,
        String subtitle,
        String authors,
        String publisher,
        Integer year,
        Integer pages,
        String language,
        String summary,
        String coverUrl) {

    private static final Pattern YEAR = Pattern.compile("\\b(\\d{4})\\b");

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
