package com.gdailly.library.repository;

import java.util.Collection;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncRunItem;

public interface SyncRunItemRepository extends JpaRepository<SyncRunItem, Long> {

    Page<SyncRunItem> findByRunIdOrderByIdDesc(Long runId, Pageable pageable);

    Page<SyncRunItem> findByRunIdAndOutcomeInOrderByIdDesc(Long runId, Collection<SyncItemOutcome> outcomes,
            Pageable pageable);
}
