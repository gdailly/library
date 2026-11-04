package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.LibraryBook;

public interface LibraryBookRepository extends JpaRepository<LibraryBook, Long>, JpaSpecificationExecutor<LibraryBook> {

    /** The library's entry of a book; books are named by their own id in the API. */
    Optional<LibraryBook> findByLibraryIdAndBookId(Long libraryId, Long bookId);

    boolean existsByLibraryIdAndBookId(Long libraryId, Long bookId);

    /** With the book's series, read outside any transaction by the ISBN lookup. */
    @EntityGraph(attributePaths = {"book", "book.seriesLinks", "book.seriesLinks.series"})
    Optional<LibraryBook> findByLibraryIdAndBookIsbn13(Long libraryId, String isbn13);

    List<LibraryBook> findByLibraryIdAndBookIdIn(Long libraryId, Collection<Long> bookIds);

    boolean existsByBookId(Long bookId);

    /** Books a metadata resynchronisation can look up. */
    @Query("select lb.book.id from LibraryBook lb where lb.libraryId = :libraryId and lb.book.isbn13 is not null "
            + "order by lb.book.id")
    List<Long> findBookIdsWithIsbn(Long libraryId);

    long countByLibraryId(Long libraryId);

    List<LibraryBook> findByLibraryIdAndBookIsbn13IsNotNull(Long libraryId, Sort sort);

    /** Every library's entries of the given books. */
    List<LibraryBook> findByBookIdIn(Collection<Long> bookIds);
}
