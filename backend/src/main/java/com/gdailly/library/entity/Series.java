package com.gdailly.library.entity;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/**
 * A series, shared by every library like the books. {@code nameKey} is the normalised name (see
 * {@code SeriesService.key}), unique; {@code status}, {@code sourceRef} and {@code fetchedAt} tell when and how the BnF
 * last listed its volumes (null: never).
 */
@Entity
public class Series {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String nameKey;

    @Enumerated(EnumType.STRING)
    private SeriesCatalogStatus status;

    /** Identifier of the BnF series record (zone 461 $0 of its volumes). */
    private String sourceRef;

    private Instant fetchedAt;

    protected Series() {
    }

    public Series(String name, String nameKey) {
        this.name = name;
        this.nameKey = nameKey;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getNameKey() {
        return nameKey;
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

    /** Records how the BnF listed the volumes. */
    public void listed(SeriesCatalogStatus status, String sourceRef, Instant fetchedAt) {
        this.status = status;
        this.sourceRef = sourceRef;
        this.fetchedAt = fetchedAt;
    }
}
