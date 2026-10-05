package com.gdailly.library.security;

import com.gdailly.library.entity.Role;

/** The authenticated member and the library the request works on. */
public record CurrentUser(Long userId, String email, Long libraryId, Role role) {

    static final String ATTRIBUTE = CurrentUser.class.getName();

    public boolean isOwner() {
        return role == Role.OWNER;
    }
}
