package com.gdailly.library.entity;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;

/**
 * When the volumes of a series were last listed, shared by every library like the ISBN cache.
 * {@code seriesKey} is the normalised series name (see {@code SeriesService.key}).
 */
@Entity
public class SeriesCatalog {

    @Id
    private String seriesKey;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SeriesCatalogStatus status;

    /** Identifier of the BnF series record (zone 461 $0 of its volumes). */
    private String sourceRef;

    @Column(nullable = false)
    private Instant fetchedAt;

    protected SeriesCatalog() {
    }

    public SeriesCatalog(String seriesKey, SeriesCatalogStatus status, String sourceRef, Instant fetchedAt) {
        this.seriesKey = seriesKey;
        this.status = status;
        this.sourceRef = sourceRef;
        this.fetchedAt = fetchedAt;
    }

    public String getSeriesKey() {
        return seriesKey;
    }

    public SeriesCatalogStatus getStatus() {
        return status;
    }

    public String getSourceRef() {
        return sourceRef;
    }

    public Instant getFetchedAt() {
        return fetchedAt;
    }

    public void update(SeriesCatalogStatus status, String sourceRef, Instant fetchedAt) {
        this.status = status;
        this.sourceRef = sourceRef;
        this.fetchedAt = fetchedAt;
    }
}
