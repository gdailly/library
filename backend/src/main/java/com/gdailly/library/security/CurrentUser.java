package com.gdailly.library.security;

import com.gdailly.library.entity.Role;

/**
 * The authenticated member and the library the request works on. {@code admin} marks the administrator of the
 * application: the account of {@code BOOTSTRAP_OWNER_EMAIL}.
 */
public record CurrentUser(Long userId, String email, Long libraryId, Role role, boolean admin) {

    static final String ATTRIBUTE = CurrentUser.class.getName();

    public CurrentUser(Long userId, String email, Long libraryId, Role role) {
        this(userId, email, libraryId, role, false);
    }

    public boolean isOwner() {
        return role == Role.OWNER;
    }
}
