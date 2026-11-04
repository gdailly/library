package com.gdailly.library.business;

import org.springframework.stereotype.Service;

import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Series;
import com.gdailly.library.repository.SeriesRepository;
import com.gdailly.library.util.Strings;

/** Finds the series of a name, creating it on first use: one series per name, case, accents and spaces ignored. */
@Service
public class SeriesRegistry {

    private final SeriesRepository series;

    SeriesRegistry(SeriesRepository series) {
        this.series = series;
    }

    /** The series of that name, created if needed; null for a blank name. Must run in a transaction. */
    Series resolve(String name) {
        String clean = Strings.trimToNull(name);
        if (clean == null) {
            return null;
        }
        String key = SeriesService.key(clean);
        return series.findByNameKey(key)
                .orElseGet(() -> series.save(new Series(clean.replaceAll("\\s+", " "), key)));
    }

    /** Puts a saved book in the series of that name only (in none when blank), as volume {@code number}. */
    void place(Book book, String name, Integer number) {
        book.placeInSeries(resolve(name), number);
    }
}
