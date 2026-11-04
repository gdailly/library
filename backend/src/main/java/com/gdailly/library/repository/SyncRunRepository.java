package com.gdailly.library.repository;

import java.time.Instant;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.SyncRun;
import com.gdailly.library.entity.SyncRunState;

public interface SyncRunRepository extends JpaRepository<SyncRun, Long> {

    Page<SyncRun> findAllByOrderByStartedAtDescIdDesc(Pageable pageable);

    /** Marks as interrupted the runs left RUNNING by a server that stopped. */
    @Modifying
    @Query("update SyncRun r set r.state = :interrupted, r.finishedAt = :at where r.state = :running")
    int interruptRunning(SyncRunState running, SyncRunState interrupted, Instant at);

    /** Deletes the finished runs started before {@code before}; their items go with them (ON DELETE CASCADE). */
    @Modifying
    @Query("delete from SyncRun r where r.startedAt < :before and r.state <> :running")
    int deleteFinishedBefore(Instant before, SyncRunState running);
}
