package com.gdailly.library.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.SeriesCatalog;

public interface SeriesCatalogRepository extends JpaRepository<SeriesCatalog, String> {
}
