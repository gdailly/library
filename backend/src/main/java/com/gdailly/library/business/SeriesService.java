package com.gdailly.library.business;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.SeriesDetailResponse;
import com.gdailly.library.dto.SeriesVolumeResponse;
import com.gdailly.library.dto.SeriesResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.Series;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.repository.BookSeriesRepository;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.SeriesRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Strings;

/**
 * The series of the library: what it owns of each, what it wishes and which volumes are missing. The volumes the
 * library does not hold are the other books of the series: listed by the BnF, or held by another library.
 */
@Service
public class SeriesService {

    /** Beyond this volume number, gaps are not listed: the number is most likely a typing error. */
    static final int MAX_LISTED_NUMBER = 500;

    private final LibraryBookRepository entries;
    private final BookSeriesRepository links;
    private final SeriesRepository seriesRepository;
    private final CoverService covers;
    private final BookService bookService;

    SeriesService(LibraryBookRepository entries, BookSeriesRepository links, SeriesRepository seriesRepository,
            CoverService covers, BookService bookService) {
        this.entries = entries;
        this.links = links;
        this.seriesRepository = seriesRepository;
        this.covers = covers;
        this.bookService = bookService;
    }

    /** Series whose name contains {@code q} (any case, any accent), by name; all when {@code q} is blank. */
    @Transactional(readOnly = true)
    public List<SeriesResponse> list(CurrentUser user, String q) {
        String filter = Strings.trimToNull(q) == null ? null : key(q);
        Map<Long, Series> held = new HashMap<>();
        links.findHeldBy(user.libraryId()).stream()
                .filter(link -> filter == null || key(link.getSeries().getNameKey()).contains(filter))
                .forEach(link -> held.putIfAbsent(link.getSeries().getId(), link.getSeries()));
        if (held.isEmpty()) {
            return List.of();
        }
        List<BookSeries> all = links.findBySeriesIds(held.keySet());
        Map<Long, LibraryBook> mine = new HashMap<>();
        entries.findByLibraryIdAndBookIdIn(user.libraryId(), all.stream().map(link -> link.getBook().getId()).toList())
                .forEach(entry -> mine.put(entry.getBook().getId(), entry));
        Map<Long, List<BookSeries>> bySeries = all.stream()
                .collect(Collectors.groupingBy(link -> link.getSeries().getId()));
        return held.values().stream()
                .map(series -> summary(series, bySeries.getOrDefault(series.getId(), List.of()), mine))
                .sorted(Comparator.comparing(SeriesResponse::name, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    /** {@code seriesLinks}: every book of the series; {@code mine}: the library's entries, by book id. */
    SeriesResponse summary(Series series, List<BookSeries> seriesLinks, Map<Long, LibraryBook> mine) {
        TreeSet<Integer> owned = new TreeSet<>();
        TreeSet<Integer> wished = new TreeSet<>();
        Set<Integer> known = new HashSet<>();
        int unnumbered = 0;
        int count = 0;
        int ownedCount = 0;
        List<BookSeries> members = new ArrayList<>();
        for (BookSeries link : seriesLinks) {
            Integer number = link.getNumber();
            if (number != null && number > 0) {
                known.add(number);
            }
            LibraryBook entry = mine.get(link.getBook().getId());
            if (entry == null) {
                continue;
            }
            members.add(link);
            count++;
            if (entry.isOwned()) {
                ownedCount++;
            }
            if (number == null || number < 1) {
                unnumbered++;
            } else if (entry.isOwned()) {
                owned.add(number);
            } else {
                wished.add(number);
            }
        }
        wished.removeAll(owned);
        Integer last = known.stream().max(Integer::compare).orElse(null);
        List<Integer> missing = new ArrayList<>();
        if (last != null) {
            for (int number = 1; number <= Math.min(last, MAX_LISTED_NUMBER); number++) {
                if (!owned.contains(number)) {
                    missing.add(number);
                }
            }
        }
        CoverResponse cover = members.stream()
                .filter(link -> link.getBook().getCoverKey() != null)
                .min(Comparator.comparing(BookSeries::getNumber, Comparator.nullsLast(Comparator.naturalOrder())))
                .map(link -> covers.urls(link.getBook()))
                .orElse(null);
        return new SeriesResponse(series.getName(), count, ownedCount, List.copyOf(owned), List.copyOf(wished),
                missing, last, unnumbered, series.getFetchedAt() == null ? null : known.size(), cover);
    }

    /**
     * One series volume by volume, from 1 to the last known volume: the library's books of each volume and, for the
     * others, the book of that number it does not hold. Books without a volume number come apart.
     */
    @Transactional(readOnly = true)
    public SeriesDetailResponse detail(CurrentUser user, String name) {
        Series series = seriesRepository.findByNameKey(key(name)).orElseThrow(NotFoundException::new);
        List<BookResponse> members = bookService.seriesBooks(user, name);
        if (members.isEmpty()) {
            throw new NotFoundException();
        }
        Set<Long> mine = new HashSet<>(members.stream().map(BookResponse::id).toList());
        Map<Integer, Book> others = new TreeMap<>();
        links.findBySeriesIds(List.of(series.getId())).stream()
                .filter(link -> link.getNumber() != null && !mine.contains(link.getBook().getId()))
                .sorted(Comparator.comparing(link -> link.getBook().getId()))
                .forEach(link -> others.putIfAbsent(link.getNumber(), link.getBook()));
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
        int last = java.util.stream.Stream.concat(byNumber.keySet().stream(), others.keySet().stream())
                .max(Integer::compare).orElse(0);
        TreeSet<Integer> numbers = new TreeSet<>(byNumber.keySet());
        numbers.addAll(others.keySet());
        for (int number = 1; number <= Math.min(last, MAX_LISTED_NUMBER); number++) {
            numbers.add(number);
        }
        List<SeriesVolumeResponse> volumes = new ArrayList<>();
        for (Integer number : numbers) {
            List<BookResponse> books = byNumber.getOrDefault(number, List.of());
            Book other = others.get(number);
            String title = !books.isEmpty() ? books.getFirst().title() : other == null ? null : other.getTitle();
            String isbn = !books.isEmpty() ? books.getFirst().isbn13() : other == null ? null : other.getIsbn13();
            Integer year = !books.isEmpty() ? books.getFirst().year() : other == null ? null : other.getYear();
            volumes.add(new SeriesVolumeResponse(number, title, isbn, year,
                    books.isEmpty() ? externalCover(isbn) : null, books));
        }
        return new SeriesDetailResponse(series.getName(), volumes, unnumbered, series.getFetchedAt());
    }

    /** Open Library's image of an ISBN, for a volume the library does not hold; 404 when it has none. */
    static String externalCover(String isbn13) {
        return isbn13 == null ? null : "https://covers.openlibrary.org/b/isbn/" + isbn13 + "-M.jpg?default=false";
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
