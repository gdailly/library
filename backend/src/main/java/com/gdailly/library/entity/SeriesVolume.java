package com.gdailly.library.entity;

import java.io.Serializable;
import java.util.Objects;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;

/** One volume of a series as listed by the BnF catalogue, whether a library owns it or not. */
@Entity
@IdClass(SeriesVolume.Key.class)
public class SeriesVolume {

    /** Composite primary key: the series and the volume number. */
    public static class Key implements Serializable {
        private String seriesKey;
        private Integer number;

        protected Key() {
        }

        public Key(String seriesKey, Integer number) {
            this.seriesKey = seriesKey;
            this.number = number;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof Key key && Objects.equals(seriesKey, key.seriesKey) && Objects.equals(number, key.number);
        }

        @Override
        public int hashCode() {
            return Objects.hash(seriesKey, number);
        }
    }

    @Id
    private String seriesKey;

    @Id
    private Integer number;

    @Column(nullable = false)
    private String title;

    private String isbn13;

    private Integer year;

    protected SeriesVolume() {
    }

    public SeriesVolume(String seriesKey, Integer number, String title, String isbn13, Integer year) {
        this.seriesKey = seriesKey;
        this.number = number;
        this.title = title;
        this.isbn13 = isbn13;
        this.year = year;
    }

    public String getSeriesKey() {
        return seriesKey;
    }

    public Integer getNumber() {
        return number;
    }

    public String getTitle() {
        return title;
    }

    public String getIsbn13() {
        return isbn13;
    }

    public Integer getYear() {
        return year;
    }
}
