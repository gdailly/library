package com.gdailly.library.dto;

/**
 * Signed cover URLs, relative to the API root and usable without the Google token (images on the web).
 * They change when the cover changes and stay identical for at least 24 h otherwise.
 */
public record CoverResponse(String thumbUrl, String mediumUrl) {
}
