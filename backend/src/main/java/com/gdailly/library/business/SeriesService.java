package com.gdailly.library.business;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.TreeSet;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Strings;

/** The series of the library: what it owns of each, what it wishes and which volumes are missing. */
@Service
public class SeriesService {

    /** Beyond this volume number, gaps are not listed: the number is most likely a typing error. */
    static final int MAX_LISTED_NUMBER = 500;

    private final BookRepository books;
    private final CoverService covers;

    SeriesService(BookRepository books, CoverService covers) {
        this.books = books;
        this.covers = covers;
    }

    /** Series whose name contains {@code q} (any case, any accent), by name; all when {@code q} is blank. */
    @Transactional(readOnly = true)
    public List<SeriesResponse> list(CurrentUser user, String q) {
        String filter = Strings.trimToNull(q) == null ? null : key(q);
        Map<String, List<Book>> bySeries = books.findByLibraryIdAndSeriesIsNotNull(user.libraryId()).stream()
                .filter(book -> !key(book.getSeries()).isEmpty())
                .collect(Collectors.groupingBy(book -> key(book.getSeries()), LinkedHashMap::new, Collectors.toList()));
        return bySeries.entrySet().stream()
                .filter(entry -> filter == null || entry.getKey().contains(filter))
                .map(entry -> summary(entry.getValue()))
                .sorted(Comparator.comparing(SeriesResponse::name, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    SeriesResponse summary(List<Book> members) {
        TreeSet<Integer> owned = new TreeSet<>();
        TreeSet<Integer> wished = new TreeSet<>();
        int unnumbered = 0;
        for (Book book : members) {
            Integer number = book.getSeriesNumber();
            if (number == null || number < 1) {
                unnumbered++;
            } else if (book.isOwned()) {
                owned.add(number);
            } else {
                wished.add(number);
            }
        }
        wished.removeAll(owned);
        Integer last = members.stream().map(Book::getSeriesNumber).filter(Objects::nonNull).filter(n -> n > 0)
                .max(Integer::compare).orElse(null);
        List<Integer> missing = new ArrayList<>();
        if (last != null) {
            for (int number = 1; number <= Math.min(last, MAX_LISTED_NUMBER); number++) {
                if (!owned.contains(number)) {
                    missing.add(number);
                }
            }
        }
        CoverResponse cover = members.stream()
                .filter(book -> book.getCoverKey() != null)
                .min(Comparator.comparing(Book::getSeriesNumber, Comparator.nullsLast(Comparator.naturalOrder())))
                .map(covers::urls)
                .orElse(null);
        return new SeriesResponse(displayName(members), members.size(),
                (int) members.stream().filter(Book::isOwned).count(), List.copyOf(owned), List.copyOf(wished),
                missing, last, unnumbered, cover);
    }

    /** The spelling most books of the series use, the first in alphabetical order on a tie. */
    private static String displayName(List<Book> members) {
        Map<String, Long> spellings = members.stream()
                .map(book -> book.getSeries().trim().replaceAll("\\s+", " "))
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
        return spellings.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed().thenComparing(Map.Entry.comparingByKey()))
                .map(Map.Entry::getKey)
                .findFirst()
                .orElseThrow();
    }

    /** Groups spellings of one series: "Une aventure d'Astérix" = "une aventure d’asterix ". */
    static String key(String series) {
        if (series == null) {
            return "";
        }
        String plain = Normalizer.normalize(series, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return plain.replace('’', '\'').toLowerCase(Locale.ROOT).replaceAll("\\s+", " ").trim();
    }
}
