package com.gdailly.library.entity;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

import org.hibernate.annotations.BatchSize;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;

/** A book a library holds ({@code owned}) or wishes for, with the library's own categories. */
@Entity
public class LibraryBook {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long libraryId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "book_id")
    private Book book;

    @Column(nullable = false)
    private boolean owned = true;

    private Long addedBy;

    @Column(nullable = false)
    private Instant createdAt;

    @ManyToMany
    @JoinTable(name = "library_book_category",
            joinColumns = @JoinColumn(name = "library_book_id"),
            inverseJoinColumns = @JoinColumn(name = "category_id"))
    @BatchSize(size = 50)
    private Set<Category> categories = new HashSet<>();

    protected LibraryBook() {
    }

    public LibraryBook(Long libraryId, Book book, Long addedBy) {
        this.libraryId = libraryId;
        this.book = book;
        this.addedBy = addedBy;
        this.createdAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public Long getLibraryId() {
        return libraryId;
    }

    public Book getBook() {
        return book;
    }

    public boolean isOwned() {
        return owned;
    }

    public void setOwned(boolean owned) {
        this.owned = owned;
    }

    public Long getAddedBy() {
        return addedBy;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Set<Category> getCategories() {
        return categories;
    }

    public void setCategories(Set<Category> categories) {
        this.categories = new HashSet<>(categories);
    }
}
