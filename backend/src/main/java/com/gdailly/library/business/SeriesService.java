package com.gdailly.library.business;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.SeriesDetailResponse;
import com.gdailly.library.dto.SeriesVolumeResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.SeriesCatalog;
import com.gdailly.library.entity.SeriesVolume;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.SeriesCatalogRepository;
import com.gdailly.library.repository.SeriesVolumeRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Strings;

/** The series of the library: what it owns of each, what it wishes and which volumes are missing. */
@Service
public class SeriesService {

    /** Beyond this volume number, gaps are not listed: the number is most likely a typing error. */
    static final int MAX_LISTED_NUMBER = 500;

    private final BookRepository books;
    private final CoverService covers;
    private final SeriesVolumeRepository catalogVolumes;
    private final SeriesCatalogRepository catalogs;
    private final BookService bookService;

    SeriesService(BookRepository books, CoverService covers, SeriesVolumeRepository catalogVolumes,
            SeriesCatalogRepository catalogs, BookService bookService) {
        this.books = books;
        this.covers = covers;
        this.catalogVolumes = catalogVolumes;
        this.catalogs = catalogs;
        this.bookService = bookService;
    }

    /** Series whose name contains {@code q} (any case, any accent), by name; all when {@code q} is blank. */
    @Transactional(readOnly = true)
    public List<SeriesResponse> list(CurrentUser user, String q) {
        String filter = Strings.trimToNull(q) == null ? null : key(q);
        Map<String, List<Book>> bySeries = books.findByLibraryIdAndSeriesIsNotNull(user.libraryId()).stream()
                .filter(book -> !key(book.getSeries()).isEmpty())
                .collect(Collectors.groupingBy(book -> key(book.getSeries()), LinkedHashMap::new, Collectors.toList()));
        List<String> keys = bySeries.keySet().stream().filter(key -> filter == null || key.contains(filter)).toList();
        Map<String, List<SeriesVolume>> catalog = keys.isEmpty() ? Map.of()
                : catalogVolumes.findBySeriesKeyInOrderByNumber(keys).stream()
                        .collect(Collectors.groupingBy(SeriesVolume::getSeriesKey));
        return keys.stream()
                .map(key -> summary(bySeries.get(key), catalog.getOrDefault(key, List.of())))
                .sorted(Comparator.comparing(SeriesResponse::name, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    /** {@code catalog}: the volumes of the series listed by the BnF, empty when not known (yet). */
    SeriesResponse summary(List<Book> members, List<SeriesVolume> catalog) {
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
        Integer last = java.util.stream.Stream.concat(
                        members.stream().map(Book::getSeriesNumber),
                        catalog.stream().map(SeriesVolume::getNumber))
                .filter(Objects::nonNull).filter(n -> n > 0)
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
                missing, last, unnumbered, catalog.isEmpty() ? null : catalog.size(), cover);
    }

    /**
     * One series volume by volume, from 1 to the last known volume: the library's books of each volume and, for the
     * others, what the BnF lists. Books without a volume number come apart.
     */
    @Transactional(readOnly = true)
    public SeriesDetailResponse detail(CurrentUser user, String name) {
        String key = key(name);
        List<BookResponse> members = bookService.seriesBooks(user, name);
        if (members.isEmpty()) {
            throw new NotFoundException();
        }
        Map<Integer, SeriesVolume> listed = catalogVolumes.findBySeriesKeyOrderByNumber(key).stream()
                .collect(Collectors.toMap(SeriesVolume::getNumber, v -> v));
        Map<Integer, List<BookResponse>> byNumber = new TreeMap<>();
        List<BookResponse> unnumbered = new ArrayList<>();
        for (BookResponse book : members) {
            Integer number = book.seriesNumber();
            if (number == null || number < 1) {
                unnumbered.add(book);
            } else {
                byNumber.computeIfAbsent(number, n -> new ArrayList<>()).add(book);
            }
        }
        int last = java.util.stream.Stream.concat(byNumber.keySet().stream(), listed.keySet().stream())
                .max(Integer::compare).orElse(0);
        TreeSet<Integer> numbers = new TreeSet<>(byNumber.keySet());
        numbers.addAll(listed.keySet());
        for (int number = 1; number <= Math.min(last, MAX_LISTED_NUMBER); number++) {
            numbers.add(number);
        }
        List<SeriesVolumeResponse> volumes = new ArrayList<>();
        for (Integer number : numbers) {
            List<BookResponse> books = byNumber.getOrDefault(number, List.of());
            SeriesVolume known = listed.get(number);
            String title = known != null ? known.getTitle() : books.isEmpty() ? null : books.getFirst().title();
            String isbn = known != null && known.getIsbn13() != null ? known.getIsbn13()
                    : books.isEmpty() ? null : books.getFirst().isbn13();
            volumes.add(new SeriesVolumeResponse(number, title, isbn, known == null ? null : known.getYear(),
                    books.isEmpty() ? externalCover(isbn) : null, books));
        }
        String display = members.stream().map(BookResponse::series).filter(Objects::nonNull).findFirst().orElse(name);
        return new SeriesDetailResponse(display, volumes, unnumbered,
                catalogs.findById(key).map(SeriesCatalog::getFetchedAt).orElse(null));
    }

    /** Open Library's image of an ISBN, for a volume the library does not hold; 404 when it has none. */
    static String externalCover(String isbn13) {
        return isbn13 == null ? null : "https://covers.openlibrary.org/b/isbn/" + isbn13 + "-M.jpg?default=false";
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
