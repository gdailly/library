package com.gdailly.library.dto;

import com.gdailly.library.entity.Role;

/** {@code name} and {@code avatarUrl} stay null until the member signs in for the first time. */
public record MemberResponse(Long userId, String email, String name, String avatarUrl, Role role) {
}
