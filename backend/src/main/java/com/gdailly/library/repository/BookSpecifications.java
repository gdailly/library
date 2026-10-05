package com.gdailly.library.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.Reading;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;

public final class BookSpecifications {

    private BookSpecifications() {
    }

    public static Specification<Book> matching(BookFilter filter) {
        return (book, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(book.get("libraryId"), filter.libraryId()));
            if (filter.owned() != null) {
                predicates.add(cb.equal(book.get("owned"), filter.owned()));
            }
            if (filter.pattern() != null) {
                List<Predicate> text = new ArrayList<>(List.of(
                        cb.like(cb.lower(book.get("title")), filter.pattern(), '\\'),
                        cb.like(cb.lower(book.get("subtitle")), filter.pattern(), '\\'),
                        cb.like(cb.lower(book.get("authors")), filter.pattern(), '\\')));
                if (filter.isbn13() != null) {
                    text.add(cb.equal(book.get("isbn13"), filter.isbn13()));
                }
                predicates.add(cb.or(text.toArray(Predicate[]::new)));
            }
            if (filter.categoryId() != null) {
                Subquery<Long> sub = query.subquery(Long.class);
                Root<Book> same = sub.from(Book.class);
                Join<Book, Category> category = same.join("categories");
                sub.select(same.get("id")).where(
                        cb.equal(same.get("id"), book.get("id")),
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
