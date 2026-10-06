package com.gdailly.library.dto;

import org.jspecify.annotations.Nullable;

import com.gdailly.library.entity.Role;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Body of POST /api/library/members: the Google e-mail to invite; {@code role} defaults to MEMBER. */
public record MemberRequest(
        @NotBlank @Email @Size(max = 320) String email,
        @Nullable Role role) {
}
