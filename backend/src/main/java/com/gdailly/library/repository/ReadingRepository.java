package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.Reading;

public interface ReadingRepository extends JpaRepository<Reading, Long> {

    Optional<Reading> findByBookIdAndUserId(Long bookId, Long userId);

    List<Reading> findByUserIdAndBookIdIn(Long userId, Collection<Long> bookIds);

    List<Reading> findByBookIdAndUserIdNot(Long bookId, Long userId);
}
