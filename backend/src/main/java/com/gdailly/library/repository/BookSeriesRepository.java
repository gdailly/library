package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.BookSeries;

public interface BookSeriesRepository extends JpaRepository<BookSeries, BookSeries.Key> {

    /** Every book of the given series, held by a library or only listed by the BnF. */
    @Query("select l from BookSeries l join fetch l.book join fetch l.series where l.series.id in :seriesIds")
    List<BookSeries> findBySeriesIds(Collection<Long> seriesIds);

    /** The series links of the books a library holds or wishes, for the series view. */
    @Query("select l from BookSeries l join fetch l.series where l.book.id in "
            + "(select lb.book.id from LibraryBook lb where lb.libraryId = :libraryId)")
    List<BookSeries> findHeldBy(Long libraryId);

    /** The series links of the books some library holds or wishes, for listing the volumes of every series. */
    @Query("select l from BookSeries l join fetch l.series join fetch l.book where l.book.id in "
            + "(select lb.book.id from LibraryBook lb)")
    List<BookSeries> findHeld();
}
