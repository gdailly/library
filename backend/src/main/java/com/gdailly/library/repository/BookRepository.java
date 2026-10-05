package com.gdailly.library.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import com.gdailly.library.entity.Book;

public interface BookRepository extends JpaRepository<Book, Long>, JpaSpecificationExecutor<Book> {

    Optional<Book> findByIdAndLibraryId(Long id, Long libraryId);

    boolean existsByLibraryIdAndIsbn13(Long libraryId, String isbn13);

    Optional<Book> findByLibraryIdAndIsbn13(Long libraryId, String isbn13);

    boolean existsByLibraryIdAndIsbn13AndIdNot(Long libraryId, String isbn13, Long id);
}
