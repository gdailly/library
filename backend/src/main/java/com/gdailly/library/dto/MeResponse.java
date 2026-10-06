package com.gdailly.library.dto;

import java.util.List;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.Role;

/** {@code name} and {@code avatarUrl} come from the Google account and are null until the first sign-in. */
public record MeResponse(
        Long id,
        String email,
        @Nullable String name,
        @Nullable String avatarUrl,
        List<LibrarySummary> libraries) {

    public record LibrarySummary(Long id, @Nullable String name, Role role) {
    }
}
