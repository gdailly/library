package com.gdailly.library.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.Book;

public interface BookRepository extends JpaRepository<Book, Long>, JpaSpecificationExecutor<Book> {

    Optional<Book> findByIdAndLibraryId(Long id, Long libraryId);

    boolean existsByLibraryIdAndIsbn13(Long libraryId, String isbn13);

    Optional<Book> findByLibraryIdAndIsbn13(Long libraryId, String isbn13);

    boolean existsByLibraryIdAndIsbn13AndIdNot(Long libraryId, String isbn13, Long id);

    /** Books a metadata resynchronisation can look up. */
    @Query("select b.id from Book b where b.libraryId = :libraryId and b.isbn13 is not null order by b.id")
    List<Long> findIdsWithIsbn(Long libraryId);

    long countByLibraryId(Long libraryId);

    List<Book> findByLibraryIdAndIsbn13IsNotNull(Long libraryId, Sort sort);
}
