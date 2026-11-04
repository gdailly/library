package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncRunItem;

public interface SyncRunItemRepository extends JpaRepository<SyncRunItem, Long> {

    Page<SyncRunItem> findByRunIdAndParentIdIsNullOrderByIdDesc(Long runId, Pageable pageable);

    List<SyncRunItem> findByRunIdAndParentIdOrderByIdAsc(Long runId, Long parentId);

    Page<SyncRunItem> findByRunIdAndParentIdIsNullAndOutcomeInOrderByIdDesc(Long runId, Collection<SyncItemOutcome> outcomes,
            Pageable pageable);
}
