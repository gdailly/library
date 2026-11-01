package com.gdailly.library.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;

public interface IsbnLookupRepository extends JpaRepository<IsbnLookup, String> {

    long countBySource(LookupSource source);

    /** Bulk delete; returns the number of entries removed. */
    @Modifying
    @Query("delete from IsbnLookup l where l.source = :source")
    int deleteAllBySource(LookupSource source);

    @Modifying
    @Query("delete from IsbnLookup l")
    int deleteAllEntries();
}
