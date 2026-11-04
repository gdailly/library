package com.gdailly.library.entity;

import java.io.Serializable;
import java.util.Objects;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;

/** A book belongs to a series, as its volume {@code number} (null when unnumbered). */
@Entity
public class BookSeries {

    @Embeddable
    public static class Key implements Serializable {
        @Column(name = "book_id")
        private Long bookId;
        @Column(name = "series_id")
        private Long seriesId;

        protected Key() {
        }

        public Key(Long bookId, Long seriesId) {
            this.bookId = bookId;
            this.seriesId = seriesId;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof Key key && Objects.equals(bookId, key.bookId) && Objects.equals(seriesId, key.seriesId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(bookId, seriesId);
        }
    }

    @EmbeddedId
    private Key id = new Key();

    @MapsId("bookId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id")
    private Book book;

    @MapsId("seriesId")
    @ManyToOne
    @JoinColumn(name = "series_id")
    private Series series;

    private Integer number;

    protected BookSeries() {
    }

    public BookSeries(Book book, Series series, Integer number) {
        this.book = book;
        this.series = series;
        this.number = number;
    }

    public Book getBook() {
        return book;
    }

    public Series getSeries() {
        return series;
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
        this.number = number;
    }
}
