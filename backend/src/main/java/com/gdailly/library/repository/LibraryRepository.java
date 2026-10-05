package com.gdailly.library.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.Library;

public interface LibraryRepository extends JpaRepository<Library, Long> {
}
