package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByLibraryIdOrderByName(Long libraryId);

    List<Category> findByLibraryIdAndIdIn(Long libraryId, Collection<Long> ids);

    Optional<Category> findByIdAndLibraryId(Long id, Long libraryId);

    boolean existsByLibraryIdAndNameIgnoreCase(Long libraryId, String name);

    boolean existsByLibraryIdAndNameIgnoreCaseAndIdNot(Long libraryId, String name, Long id);
}
