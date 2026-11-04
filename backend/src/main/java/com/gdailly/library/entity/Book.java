package com.gdailly.library.entity;

import java.time.Instant;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Set;

import org.hibernate.annotations.BatchSize;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

/**
 * A book itself, as the ISBN lookup describes it, shared by every library: one row per ISBN. What a library owns or
 * wishes is a {@link LibraryBook}; the series it belongs to are {@link BookSeries}.
 */
@Entity
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String isbn13;

    @Column(nullable = false)
    private String title;

    private String subtitle;

    private String authors;

    private String publisher;

    private Integer year;

    private Integer pages;

    private String language;

    private String coverKey;

    private String summary;

    @Column(nullable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "book", cascade = CascadeType.ALL, orphanRemoval = true)
    @BatchSize(size = 50)
    private Set<BookSeries> seriesLinks = new HashSet<>();

    public Book() {
        this.createdAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public String getIsbn13() {
        return isbn13;
    }

    public void setIsbn13(String isbn13) {
        this.isbn13 = isbn13;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getAuthors() {
        return authors;
    }

    public void setAuthors(String authors) {
        this.authors = authors;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getPages() {
        return pages;
    }

    public void setPages(Integer pages) {
        this.pages = pages;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getCoverKey() {
        return coverKey;
    }

    public void setCoverKey(String coverKey) {
        this.coverKey = coverKey;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Set<BookSeries> getSeriesLinks() {
        return seriesLinks;
    }

    /** The series shown with the book: the first one by name (a book is rarely in more than one). */
    public BookSeries mainSeries() {
        return seriesLinks.stream()
                .min(Comparator.comparing(link -> link.getSeries().getName(), String.CASE_INSENSITIVE_ORDER))
                .orElse(null);
    }

    public String getSeriesName() {
        BookSeries main = mainSeries();
        return main == null ? null : main.getSeries().getName();
    }

    public Integer getSeriesNumber() {
        BookSeries main = mainSeries();
        return main == null ? null : main.getNumber();
    }

    /** Puts the book in {@code series} only (none when null), as volume {@code number}. */
    public void placeInSeries(Series series, Integer number) {
        if (series == null) {
            seriesLinks.clear();
            return;
        }
        seriesLinks.removeIf(link -> !link.getSeries().getNameKey().equals(series.getNameKey()));
        seriesLinks.stream().findFirst().ifPresentOrElse(link -> link.setNumber(number),
                () -> seriesLinks.add(new BookSeries(this, series, number)));
    }
}
