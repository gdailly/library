package com.gdailly.library.dto;

/** Sizes served by GET /api/books/{id}/cover: thumb (160×240 WebP) and medium (480×720 WebP). */
public enum CoverSize {
    THUMB,
    MEDIUM;

    public String queryValue() {
        return name().toLowerCase();
    }
}
