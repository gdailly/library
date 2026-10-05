package com.gdailly.library.mapper;

import java.util.Comparator;
import java.util.List;

import com.gdailly.library.dto.BookRequest;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.Reading;

public final class BookMapper {

    private BookMapper() {
    }

    /** {@code myReading} is the caller's reading of this book, {@code cover} its signed URLs; both may be null. */
    public static BookResponse toResponse(Book book, Reading myReading, CoverResponse cover) {
        List<CategoryResponse> categories = book.getCategories().stream()
                .sorted(Comparator.comparing(Category::getName, String.CASE_INSENSITIVE_ORDER))
                .map(CategoryMapper::toResponse)
                .toList();
        return new BookResponse(book.getId(), book.getIsbn13(), book.getTitle(), book.getSubtitle(), book.getAuthors(),
                book.getPublisher(), book.getYear(), book.getPages(), book.getLanguage(), book.getSummary(),
                book.isOwned(), book.getAddedBy(), book.getCreatedAt(), categories, ReadingMapper.toResponse(myReading),
                cover);
    }

    /**
     * Copies the editable fields, trimmed, blanks as null.
     * The ISBN and categories are set by the business layer once validated.
     */
    public static void updateEntity(Book book, BookRequest request) {
        book.setTitle(request.title().trim());
        book.setSubtitle(blankToNull(request.subtitle()));
        book.setAuthors(blankToNull(request.authors()));
        book.setPublisher(blankToNull(request.publisher()));
        book.setYear(request.year());
        book.setPages(request.pages());
        book.setLanguage(blankToNull(request.language()));
        book.setSummary(blankToNull(request.summary()));
        book.setOwned(request.owned() == null || request.owned());
    }

    public static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
