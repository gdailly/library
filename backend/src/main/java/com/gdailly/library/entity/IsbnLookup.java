package com.gdailly.library.entity;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;

/** Cached answer of the external metadata APIs for one ISBN, raw as received. */
@Entity
public class IsbnLookup {

    @Id
    private String isbn13;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LookupSource source;

    /** Raw JSON returned by {@link #source}; null when NOT_FOUND. */
    private String payload;

    private String coverKey;

    @Column(nullable = false)
    private Instant fetchedAt;

    protected IsbnLookup() {
    }

    public IsbnLookup(String isbn13, LookupSource source, String payload, Instant fetchedAt) {
        this.isbn13 = isbn13;
        this.source = source;
        this.payload = payload;
        this.fetchedAt = fetchedAt;
    }

    public String getIsbn13() {
        return isbn13;
    }

    public LookupSource getSource() {
        return source;
    }

    public String getPayload() {
        return payload;
    }

    public String getCoverKey() {
        return coverKey;
    }

    public void setCoverKey(String coverKey) {
        this.coverKey = coverKey;
    }

    public Instant getFetchedAt() {
        return fetchedAt;
    }
}
