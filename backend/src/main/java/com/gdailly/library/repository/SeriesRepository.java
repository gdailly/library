package com.gdailly.library.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.Series;

public interface SeriesRepository extends JpaRepository<Series, Long> {

    Optional<Series> findByNameKey(String nameKey);
}
