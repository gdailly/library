package com.gdailly.library.business;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.gdailly.library.dto.BookRequest;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.OtherReadingResponse;
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.Reading;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.BookMapper;
import com.gdailly.library.mapper.ReadingMapper;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.BookFilter;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.BookSeriesRepository;
import com.gdailly.library.repository.BookSpecifications;
import com.gdailly.library.repository.CategoryRepository;
import com.gdailly.library.repository.LibraryBookRepository;
import com.gdailly.library.repository.SeriesRepository;
import com.gdailly.library.repository.ReadingRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Isbn;
import com.gdailly.library.util.Strings;

/**
 * The books of a library: each is a shared {@link Book} (one per ISBN) and the library's own {@link LibraryBook}
 * (owned or wished, categories). The API names a book by the book's own id.
 */
@Service
public class BookService {

    static final int PAGE_SIZE = 50;

    private final BookRepository books;
    private final LibraryBookRepository entries;
    private final BookSeriesRepository seriesLinks;
    private final SeriesRepository series;
    private final SeriesRegistry seriesRegistry;
    private final CategoryRepository categories;
    private final ReadingRepository readings;
    private final AppUserRepository users;
    private final CoverService covers;
    private final TransactionTemplate transaction;
    private final BookMapper bookMapper;
    private final ReadingMapper readingMapper;

    BookService(BookRepository books, LibraryBookRepository entries, BookSeriesRepository seriesLinks,
            SeriesRepository series, SeriesRegistry seriesRegistry, CategoryRepository categories,
            ReadingRepository readings, AppUserRepository users, CoverService covers,
            PlatformTransactionManager transactionManager, BookMapper bookMapper, ReadingMapper readingMapper) {
        this.books = books;
        this.entries = entries;
        this.seriesLinks = seriesLinks;
        this.series = series;
        this.seriesRegistry = seriesRegistry;
        this.categories = categories;
        this.readings = readings;
        this.users = users;
        this.covers = covers;
        this.transaction = new TransactionTemplate(transactionManager);
        this.bookMapper = bookMapper;
        this.readingMapper = readingMapper;
    }

    /** Criteria of GET /api/books; null means no filter. {@code status} and {@code minRating} apply to the caller's readings. */
    public record SearchCriteria(String q, Boolean owned, Long categoryId, ReadingStatus status, Integer minRating) {
    }

    @Transactional(readOnly = true)
    public PageResponse<BookResponse> search(CurrentUser user, SearchCriteria criteria, int page) {
        PageRequest pageable = PageRequest.of(Math.max(page, 0), PAGE_SIZE, Sort.by("book.title", "book.id"));
        Page<LibraryBook> result = entries.findAll(BookSpecifications.matching(filterFor(user, criteria)), pageable);

        Function<LibraryBook, BookResponse> mapper = listMapper(user, result.getContent());
        return PageResponse.of(result, mapper);
    }

    /** The library's books of a series (same name, ignoring case, accents and spaces), by volume number, then title. */
    @Transactional(readOnly = true)
    public List<BookResponse> seriesBooks(CurrentUser user, String name) {
        List<LibraryBook> found = series.findByNameKey(SeriesService.key(name))
                .map(one -> heldOf(user.libraryId(), seriesLinks.findBySeriesIds(List.of(one.getId()))))
                .orElse(List.of());
        return found.stream().map(listMapper(user, found)).toList();
    }

    /** The library's entries of the linked books, by volume number, then title. */
    List<LibraryBook> heldOf(Long libraryId, List<BookSeries> links) {
        Map<Long, Integer> numbers = new HashMap<>();
        links.forEach(link -> numbers.put(link.getBook().getId(), link.getNumber()));
        if (numbers.isEmpty()) {
            return List.of();
        }
        return entries.findByLibraryIdAndBookIdIn(libraryId, numbers.keySet()).stream()
                .sorted(Comparator.comparing((LibraryBook entry) -> numbers.get(entry.getBook().getId()),
                                Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparing(entry -> entry.getBook().getTitle(), String.CASE_INSENSITIVE_ORDER)
                        .thenComparing(entry -> entry.getBook().getId()))
                .toList();
    }

    /** Maps books as in a list: the caller's own reading and the cover, without the other members' readings. */
    private Function<LibraryBook, BookResponse> listMapper(CurrentUser user, List<LibraryBook> found) {
        List<Long> ids = found.stream().map(entry -> entry.getBook().getId()).toList();
        Map<Long, Reading> myReadings = ids.isEmpty() ? Map.of()
                : readings.findByUserIdAndBookIdIn(user.userId(), ids).stream()
                        .collect(Collectors.toMap(Reading::getBookId, Function.identity()));
        Map<Long, String> names = names(found.stream().map(LibraryBook::getAddedBy).toList());
        return entry -> bookMapper.toResponse(entry, myReadings.get(entry.getBook().getId()),
                covers.urls(entry.getBook()), nameOf(names, entry.getAddedBy()), List.of());
    }

    @Transactional(readOnly = true)
    public BookResponse get(CurrentUser user, Long id) {
        return toResponse(user, find(user, id));
    }

    /**
     * Adds a book to the library. A book another library holds, or that the BnF lists in a series, is the same book:
     * it is reused, and the fields sent describe it from now on. A book added after an ISBN lookup gets that lookup's
     * cover, downloaded outside the transaction.
     */
    public BookResponse create(CurrentUser user, BookRequest request) {
        String coverKey = Isbn.toIsbn13(request.isbn()).flatMap(covers::importFromIsbn).orElse(null);
        return transaction.execute(status -> {
            String isbn13 = isbn13(request);
            Book book = isbn13 == null ? new Book() : books.findByIsbn13(isbn13).orElseGet(Book::new);
            if (book.getId() != null && entries.existsByLibraryIdAndBookId(user.libraryId(), book.getId())) {
                throw new ConflictException("Ce livre est déjà dans la bibliothèque.");
            }
            book.setIsbn13(isbn13);
            describe(book, request);
            if (book.getCoverKey() == null) {
                book.setCoverKey(coverKey);
            }
            book = books.save(book);
            seriesRegistry.place(book, request.series(), request.seriesNumber());
            LibraryBook entry = new LibraryBook(user.libraryId(), book, user.userId());
            hold(user, entry, request);
            return toResponse(user, entries.save(entry));
        });
    }

    @Transactional
    public BookResponse update(CurrentUser user, Long id, BookRequest request) {
        LibraryBook entry = find(user, id);
        Book book = entry.getBook();
        String isbn13 = isbn13(request);
        if (isbn13 != null && books.existsByIsbn13AndIdNot(isbn13, book.getId())) {
            throw new ConflictException("Un autre livre porte déjà cet ISBN.");
        }
        book.setIsbn13(isbn13);
        describe(book, request);
        seriesRegistry.place(book, request.series(), request.seriesNumber());
        hold(user, entry, request);
        return toResponse(user, entry);
    }

    /**
     * Removes the book from the library. Held by no library any more, the book goes with its readings, unless the BnF
     * lists it in a series: it then stays as a volume of that series.
     */
    @Transactional
    public void delete(CurrentUser user, Long id) {
        LibraryBook entry = find(user, id);
        Book book = entry.getBook();
        entries.delete(entry);
        entries.flush();
        if (!entries.existsByBookId(book.getId())) {
            if (book.getSeriesLinks().isEmpty()) {
                books.delete(book);
            } else {
                readings.deleteByBookId(book.getId());
            }
        }
    }

    LibraryBook find(CurrentUser user, Long id) {
        return entries.findByLibraryIdAndBookId(user.libraryId(), id).orElseThrow(NotFoundException::new);
    }

    /** A single book, with the readings of the other members. */
    BookResponse toResponse(CurrentUser user, LibraryBook entry) {
        Book book = entry.getBook();
        Reading myReading = readings.findByBookIdAndUserId(book.getId(), user.userId()).orElse(null);
        List<Reading> others = readings.findByBookIdAndUserIdNot(book.getId(), user.userId());
        List<Long> userIds = new ArrayList<>(others.stream().map(Reading::getUserId).toList());
        userIds.add(entry.getAddedBy());
        Map<Long, String> names = names(userIds);
        List<OtherReadingResponse> otherReadings = others.stream()
                .filter(reading -> names.containsKey(reading.getUserId()))
                .sorted(Comparator.comparing(reading -> names.get(reading.getUserId()), String.CASE_INSENSITIVE_ORDER))
                .map(reading -> readingMapper.toOtherReading(reading, names.get(reading.getUserId())))
                .toList();
        return bookMapper.toResponse(entry, myReading, covers.urls(book), nameOf(names, entry.getAddedBy()),
                otherReadings);
    }

    /** Immutable maps reject null keys: a book whose member left has no author id. */
    private static String nameOf(Map<Long, String> names, Long userId) {
        return userId == null ? null : names.get(userId);
    }

    /** Display names of members, by user id; null ids and unknown users are left out. */
    private Map<Long, String> names(Collection<Long> userIds) {
        Set<Long> ids = userIds.stream().filter(Objects::nonNull).collect(Collectors.toSet());
        return ids.isEmpty() ? Map.of()
                : users.findAllById(ids).stream().collect(Collectors.toMap(AppUser::getId, AppUser::displayName));
    }

    private static String isbn13(BookRequest request) {
        String isbn = Strings.trimToNull(request.isbn());
        return isbn == null ? null
                : Isbn.toIsbn13(isbn).orElseThrow(() -> new BadRequestException("ISBN invalide : " + isbn));
    }

    private void describe(Book book, BookRequest request) {
        bookMapper.updateBook(request, book);
    }

    /** What the library says of the book: owned (by default) or wished, and its categories. */
    private void hold(CurrentUser user, LibraryBook entry, BookRequest request) {
        entry.setOwned(request.owned() == null || request.owned());
        entry.setCategories(resolveCategories(user, request.categoryIds()));
    }

    private Set<Category> resolveCategories(CurrentUser user, List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Set.of();
        }
        Set<Long> wanted = new HashSet<>(ids);
        List<Category> found = categories.findByLibraryIdAndIdIn(user.libraryId(), wanted);
        if (found.size() != wanted.size()) {
            throw new BadRequestException("Catégorie inconnue.");
        }
        return new HashSet<>(found);
    }

    /** The text searched as typed (case-insensitive), and also as an ISBN when it is one. */
    static BookFilter filterFor(CurrentUser user, SearchCriteria criteria) {
        String text = Strings.trimToNull(criteria.q());
        return new BookFilter(
                user.libraryId(),
                text == null ? null : "%" + escapeLike(text.toLowerCase(Locale.ROOT)) + "%",
                text == null ? null : Isbn.toIsbn13(text).orElse(null),
                criteria.owned(),
                criteria.categoryId(),
                user.userId(),
                criteria.status(),
                criteria.minRating());
    }

    /** Escapes the LIKE wildcards typed by the user, so that "100%" matches literally. */
    static String escapeLike(String value) {
        return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
