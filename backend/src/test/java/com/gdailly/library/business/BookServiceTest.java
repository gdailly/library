package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import com.gdailly.library.dto.BookRequest;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.Reading;
import com.gdailly.library.entity.ReadingStatus;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.BookMapperImpl;
import com.gdailly.library.mapper.CategoryMapperImpl;
import com.gdailly.library.mapper.ReadingMapperImpl;
import com.gdailly.library.repository.BookFilter;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.CategoryRepository;
import com.gdailly.library.repository.ReadingRepository;
import com.gdailly.library.security.CurrentUser;

class BookServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "alice@example.com", 1L, Role.MEMBER);

    private final BookRepository books = mock(BookRepository.class);
    private final CategoryRepository categories = mock(CategoryRepository.class);
    private final ReadingRepository readings = mock(ReadingRepository.class);
    private final CoverService covers = mock(CoverService.class);
    private final BookService service = new BookService(books, categories, readings, covers,
            mock(PlatformTransactionManager.class),
            new BookMapperImpl(new CategoryMapperImpl(), new ReadingMapperImpl()));

    @BeforeEach
    void setUp() {
        when(books.save(any())).thenAnswer(call -> {
            Book book = call.getArgument(0);
            ReflectionTestUtils.setField(book, "id", 42L);
            return book;
        });
        when(covers.importFromIsbn(anyString())).thenReturn(Optional.empty());
        when(readings.findByBookIdAndUserId(anyLong(), anyLong())).thenReturn(Optional.empty());
    }

    @Test
    void createsOwnedBookWithNormalisedIsbnAndTrimmedFields() {
        BookResponse response = service.create(USER, request("2-07-061275-9", "  Le Petit Prince ", null, List.of()));

        assertThat(response.id()).isEqualTo(42L);
        assertThat(response.isbn13()).isEqualTo("9782070612758");
        assertThat(response.title()).isEqualTo("Le Petit Prince");
        assertThat(response.owned()).isTrue();
        assertThat(response.addedBy()).isEqualTo(7L);
        assertThat(response.categories()).isEmpty();
        assertThat(response.cover()).isNull();
    }

    @Test
    void attachesTheCoverOfTheIsbnLookup() {
        when(covers.importFromIsbn("9782070612758")).thenReturn(Optional.of("a".repeat(64)));

        service.create(USER, request("9782070612758", "Le Petit Prince", null, null));

        assertThat(savedBook().getCoverKey()).isEqualTo("a".repeat(64));
    }

    @Test
    void doesNotLookForACoverWithoutIsbn() {
        service.create(USER, request(null, "Carnet", null, null));
        verify(covers, never()).importFromIsbn(anyString());
    }

    @Test
    void refusesInvalidIsbn() {
        assertThatThrownBy(() -> service.create(USER, request("12345", "Livre", null, null)))
                .isInstanceOf(BadRequestException.class);
        verify(books, never()).save(any());
    }

    @Test
    void refusesDuplicateIsbnInTheLibrary() {
        when(books.existsByLibraryIdAndIsbn13(1L, "9782070612758")).thenReturn(true);

        assertThatThrownBy(() -> service.create(USER, request("9782070612758", "Le Petit Prince", null, null)))
                .isInstanceOf(ConflictException.class);
        verify(books, never()).save(any());
    }

    @Test
    void attachesCategoriesOfTheLibraryOnly() {
        Category poetry = category(3L, "Poésie");
        Category classics = category(4L, "Classiques");
        when(categories.findByLibraryIdAndIdIn(1L, Set.of(3L, 4L))).thenReturn(List.of(poetry, classics));

        BookResponse response = service.create(USER, request(null, "Les Fleurs du mal", null, List.of(3L, 4L, 3L)));

        assertThat(response.categories()).extracting("name").containsExactly("Classiques", "Poésie");
    }

    @Test
    void refusesUnknownCategory() {
        when(categories.findByLibraryIdAndIdIn(1L, Set.of(3L, 99L))).thenReturn(List.of(category(3L, "Poésie")));

        assertThatThrownBy(() -> service.create(USER, request(null, "Livre", null, List.of(3L, 99L))))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void keepsOwnedFalseForWishList() {
        assertThat(service.create(USER, request(null, "Envie", false, null)).owned()).isFalse();
    }

    @Test
    void updateRefusesIsbnOfAnotherBook() {
        Book book = new Book(1L, 7L);
        ReflectionTestUtils.setField(book, "id", 5L);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(books.existsByLibraryIdAndIsbn13AndIdNot(1L, "9782070612758", 5L)).thenReturn(true);

        assertThatThrownBy(() -> service.update(USER, 5L, request("9782070612758", "Doublon", null, null)))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void doesNotFindBooksOfAnotherLibrary() {
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.get(USER, 5L)).isInstanceOf(NotFoundException.class);
        assertThatThrownBy(() -> service.delete(USER, 5L)).isInstanceOf(NotFoundException.class);
    }

    @Test
    void includesMyReading() {
        Book book = new Book(1L, 2L);
        ReflectionTestUtils.setField(book, "id", 5L);
        Reading reading = new Reading(5L, 7L);
        reading.setStatus(ReadingStatus.READING);
        when(books.findByIdAndLibraryId(5L, 1L)).thenReturn(Optional.of(book));
        when(readings.findByBookIdAndUserId(5L, 7L)).thenReturn(Optional.of(reading));

        assertThat(service.get(USER, 5L).myReading().status()).isEqualTo(ReadingStatus.READING);
    }

    @Test
    @SuppressWarnings("unchecked")
    void searchesFirstPageOfFiftyByTitle() {
        Page<Book> empty = new PageImpl<>(List.of());
        when(books.findAll(any(Specification.class), any(Pageable.class))).thenReturn(empty);

        service.search(USER, new BookService.SearchCriteria(null, null, null, null, null), -3);

        ArgumentCaptor<Pageable> pageable = ArgumentCaptor.forClass(Pageable.class);
        verify(books).findAll(any(Specification.class), pageable.capture());
        assertThat(pageable.getValue().getPageNumber()).isZero();
        assertThat(pageable.getValue().getPageSize()).isEqualTo(50);
        assertThat(pageable.getValue().getSort()).isEqualTo(Sort.by("title", "id"));
        verify(readings, never()).findByUserIdAndBookIdIn(anyLong(), any());
    }

    @Test
    @SuppressWarnings("unchecked")
    void searchReturnsBooksWithMyReadings() {
        Book read = new Book(1L, 2L);
        ReflectionTestUtils.setField(read, "id", 5L);
        read.setTitle("Lu");
        Book unread = new Book(1L, 2L);
        ReflectionTestUtils.setField(unread, "id", 6L);
        unread.setTitle("Pas lu");
        Reading reading = new Reading(5L, 7L);
        reading.setStatus(ReadingStatus.READ);
        when(books.findAll(any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(read, unread), Pageable.ofSize(50), 2));
        when(readings.findByUserIdAndBookIdIn(7L, List.of(5L, 6L))).thenReturn(List.of(reading));

        var page = service.search(USER, new BookService.SearchCriteria("lu", null, null, null, null), 0);

        assertThat(page.totalItems()).isEqualTo(2);
        assertThat(page.items()).extracting(BookResponse::title).containsExactly("Lu", "Pas lu");
        assertThat(page.items().get(0).myReading().status()).isEqualTo(ReadingStatus.READ);
        assertThat(page.items().get(1).myReading()).isNull();
    }

    @Test
    void buildsFilterFromCriteria() {
        BookFilter filter = BookService.filterFor(USER,
                new BookService.SearchCriteria("  Le PETIT ", false, 3L, ReadingStatus.READ, 4));

        assertThat(filter).isEqualTo(new BookFilter(1L, "%le petit%", null, false, 3L, 7L, ReadingStatus.READ, 4));
    }

    @Test
    void alsoSearchesTypedTextAsIsbn() {
        BookFilter filter = BookService.filterFor(USER, new BookService.SearchCriteria("2-07-061275-9", null, null, null, null));

        assertThat(filter.pattern()).isEqualTo("%2-07-061275-9%");
        assertThat(filter.isbn13()).isEqualTo("9782070612758");
    }

    @Test
    void ignoresBlankText() {
        BookFilter filter = BookService.filterFor(USER, new BookService.SearchCriteria("   ", null, null, null, null));

        assertThat(filter.pattern()).isNull();
        assertThat(filter.isbn13()).isNull();
    }

    @Test
    void escapesLikeWildcards() {
        assertThat(BookService.escapeLike("100%_c\\")).isEqualTo("100\\%\\_c\\\\");
    }

    private Book savedBook() {
        ArgumentCaptor<Book> saved = ArgumentCaptor.forClass(Book.class);
        verify(books).save(saved.capture());
        return saved.getValue();
    }

    private static Category category(long id, String name) {
        Category category = new Category(1L);
        ReflectionTestUtils.setField(category, "id", id);
        category.setName(name);
        category.setColor("#1F5E4B");
        return category;
    }

    private static BookRequest request(String isbn, String title, Boolean owned, List<Long> categoryIds) {
        return new BookRequest(isbn, title, null, null, null, null, null, null, null, owned, categoryIds);
    }
}
