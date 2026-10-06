package com.gdailly.library.business;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
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
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.Reading;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.BookMapper;
import com.gdailly.library.repository.BookFilter;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.BookSpecifications;
import com.gdailly.library.repository.CategoryRepository;
import com.gdailly.library.repository.ReadingRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Isbn;
import com.gdailly.library.util.Strings;

@Service
public class BookService {

    static final int PAGE_SIZE = 50;

    private final BookRepository books;
    private final CategoryRepository categories;
    private final ReadingRepository readings;
    private final CoverService covers;
    private final TransactionTemplate transaction;
    private final BookMapper bookMapper;

    BookService(BookRepository books, CategoryRepository categories, ReadingRepository readings, CoverService covers,
            PlatformTransactionManager transactionManager, BookMapper bookMapper) {
        this.books = books;
        this.categories = categories;
        this.readings = readings;
        this.covers = covers;
        this.transaction = new TransactionTemplate(transactionManager);
        this.bookMapper = bookMapper;
    }

    /** Criteria of GET /api/books; null means no filter. {@code status} and {@code minRating} apply to the caller's readings. */
    public record SearchCriteria(String q, Boolean owned, Long categoryId, ReadingStatus status, Integer minRating) {
    }

    @Transactional(readOnly = true)
    public PageResponse<BookResponse> search(CurrentUser user, SearchCriteria criteria, int page) {
        PageRequest pageable = PageRequest.of(Math.max(page, 0), PAGE_SIZE, Sort.by("title", "id"));
        Page<Book> result = books.findAll(BookSpecifications.matching(filterFor(user, criteria)), pageable);

        List<Long> ids = result.getContent().stream().map(Book::getId).toList();
        Map<Long, Reading> myReadings = ids.isEmpty() ? Map.of()
                : readings.findByUserIdAndBookIdIn(user.userId(), ids).stream()
                        .collect(Collectors.toMap(Reading::getBookId, Function.identity()));
        return PageResponse.of(result,
                book -> bookMapper.toResponse(book, myReadings.get(book.getId()), covers.urls(book)));
    }

    @Transactional(readOnly = true)
    public BookResponse get(CurrentUser user, Long id) {
        return toResponse(user, find(user, id));
    }

    /** A book added after an ISBN lookup gets that lookup's cover, downloaded outside the transaction. */
    public BookResponse create(CurrentUser user, BookRequest request) {
        String coverKey = Isbn.toIsbn13(request.isbn()).flatMap(covers::importFromIsbn).orElse(null);
        return transaction.execute(status -> {
            Book book = new Book(user.libraryId(), user.userId());
            apply(user, book, request);
            if (book.getIsbn13() != null && books.existsByLibraryIdAndIsbn13(user.libraryId(), book.getIsbn13())) {
                throw new ConflictException("Ce livre est déjà dans la bibliothèque.");
            }
            book.setCoverKey(coverKey);
            return toResponse(user, books.save(book));
        });
    }

    @Transactional
    public BookResponse update(CurrentUser user, Long id, BookRequest request) {
        Book book = find(user, id);
        apply(user, book, request);
        if (book.getIsbn13() != null && books.existsByLibraryIdAndIsbn13AndIdNot(user.libraryId(), book.getIsbn13(), id)) {
            throw new ConflictException("Un autre livre porte déjà cet ISBN.");
        }
        return toResponse(user, book);
    }

    @Transactional
    public void delete(CurrentUser user, Long id) {
        books.delete(find(user, id));
    }

    Book find(CurrentUser user, Long id) {
        return books.findByIdAndLibraryId(id, user.libraryId()).orElseThrow(NotFoundException::new);
    }

    BookResponse toResponse(CurrentUser user, Book book) {
        Reading myReading = book.getId() == null ? null
                : readings.findByBookIdAndUserId(book.getId(), user.userId()).orElse(null);
        return bookMapper.toResponse(book, myReading, covers.urls(book));
    }

    private void apply(CurrentUser user, Book book, BookRequest request) {
        String isbn = Strings.trimToNull(request.isbn());
        book.setIsbn13(isbn == null ? null
                : Isbn.toIsbn13(isbn).orElseThrow(() -> new BadRequestException("ISBN invalide : " + isbn)));
        bookMapper.updateEntity(request, book);
        book.setCategories(resolveCategories(user, request.categoryIds()));
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
