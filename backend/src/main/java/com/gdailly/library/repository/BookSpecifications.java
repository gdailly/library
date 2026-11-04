package com.gdailly.library.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.BookSeries;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.Series;
import com.gdailly.library.entity.Reading;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;

public final class BookSpecifications {

    private BookSpecifications() {
    }

    /** What a library holds or wishes, matching the filter; sorted on {@code book.title}. */
    public static Specification<LibraryBook> matching(BookFilter filter) {
        return (entry, query, cb) -> {
            Join<LibraryBook, Book> book = entry.join("book");
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(entry.get("libraryId"), filter.libraryId()));
            if (filter.owned() != null) {
                predicates.add(cb.equal(entry.get("owned"), filter.owned()));
            }
            if (filter.pattern() != null) {
                Subquery<Long> inSeries = query.subquery(Long.class);
                Root<BookSeries> link = inSeries.from(BookSeries.class);
                Join<BookSeries, Series> series = link.join("series");
                inSeries.select(link.get("book").get("id")).where(
                        cb.equal(link.get("book").get("id"), book.get("id")),
                        cb.like(cb.lower(series.get("name")), filter.pattern(), '\\'));
                List<Predicate> text = new ArrayList<>(List.of(
                        cb.like(cb.lower(book.get("title")), filter.pattern(), '\\'),
                        cb.like(cb.lower(book.get("subtitle")), filter.pattern(), '\\'),
                        cb.exists(inSeries),
                        cb.like(cb.lower(book.get("authors")), filter.pattern(), '\\')));
                if (filter.isbn13() != null) {
                    text.add(cb.equal(book.get("isbn13"), filter.isbn13()));
                }
                predicates.add(cb.or(text.toArray(Predicate[]::new)));
            }
            if (filter.categoryId() != null) {
                Subquery<Long> sub = query.subquery(Long.class);
                Root<LibraryBook> same = sub.from(LibraryBook.class);
                Join<LibraryBook, Category> category = same.join("categories");
                sub.select(same.get("id")).where(
                        cb.equal(same.get("id"), entry.get("id")),
                        cb.equal(category.get("id"), filter.categoryId()));
                predicates.add(cb.exists(sub));
            }
            if (filter.status() != null || filter.minRating() != null) {
                Subquery<Long> sub = query.subquery(Long.class);
                Root<Reading> reading = sub.from(Reading.class);
                List<Predicate> conditions = new ArrayList<>(List.of(
                        cb.equal(reading.get("bookId"), book.get("id")),
                        cb.equal(reading.get("userId"), filter.userId())));
                if (filter.status() != null) {
                    conditions.add(cb.equal(reading.get("status"), filter.status()));
                }
                if (filter.minRating() != null) {
                    conditions.add(cb.greaterThanOrEqualTo(reading.get("rating"), filter.minRating()));
                }
                sub.select(reading.get("id")).where(conditions.toArray(Predicate[]::new));
                predicates.add(cb.exists(sub));
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
    }
}
