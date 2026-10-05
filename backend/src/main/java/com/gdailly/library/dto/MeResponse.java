package com.gdailly.library.dto;

import java.util.List;

import com.gdailly.library.entity.Role;

public record MeResponse(Long id, String email, String name, String avatarUrl, List<LibrarySummary> libraries) {

    public record LibrarySummary(Long id, String name, Role role) {
    }
}
