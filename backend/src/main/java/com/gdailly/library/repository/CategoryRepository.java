package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.gdailly.library.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByLibraryIdOrderByName(Long libraryId);

    List<Category> findByLibraryIdAndIdIn(Long libraryId, Collection<Long> ids);

    Optional<Category> findByIdAndLibraryId(Long id, Long libraryId);

    boolean existsByLibraryIdAndNameIgnoreCase(Long libraryId, String name);

    boolean existsByLibraryIdAndNameIgnoreCaseAndIdNot(Long libraryId, String name, Long id);

    /** Number of books per category of a library, as [category id, count] rows; categories without book are absent. */
    @Query("select c.id, count(b) from Book b join b.categories c where c.libraryId = :libraryId group by c.id")
    List<Object[]> countBooksByCategory(@Param("libraryId") Long libraryId);
}
