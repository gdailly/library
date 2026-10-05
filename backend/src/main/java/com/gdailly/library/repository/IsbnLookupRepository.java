package com.gdailly.library.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.IsbnLookup;

public interface IsbnLookupRepository extends JpaRepository<IsbnLookup, String> {
}
