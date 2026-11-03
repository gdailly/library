package com.gdailly.library.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import com.gdailly.library.entity.SeriesVolume;

public interface SeriesVolumeRepository extends JpaRepository<SeriesVolume, SeriesVolume.Key> {

    List<SeriesVolume> findBySeriesKeyInOrderByNumber(Collection<String> seriesKeys);

    List<SeriesVolume> findBySeriesKeyOrderByNumber(String seriesKey);

    @Modifying
    @Query("delete from SeriesVolume v where v.seriesKey = :seriesKey")
    void deleteBySeriesKey(String seriesKey);
}
