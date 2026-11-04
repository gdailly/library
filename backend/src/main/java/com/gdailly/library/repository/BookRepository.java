package com.gdailly.library.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.Book;

public interface BookRepository extends JpaRepository<Book, Long> {

    Optional<Book> findByIsbn13(String isbn13);

    boolean existsByIsbn13AndIdNot(String isbn13, Long id);
}
