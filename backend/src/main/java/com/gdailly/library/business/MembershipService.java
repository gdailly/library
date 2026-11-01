package com.gdailly.library.business;

import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.security.CurrentUser;

@Service
public class MembershipService {

    private final AppUserRepository users;
    private final LibraryMemberRepository members;
    private final String adminEmail;

    MembershipService(AppUserRepository users, LibraryMemberRepository members, LivreProperties properties) {
        this.users = users;
        this.members = members;
        this.adminEmail = properties.bootstrap().ownerEmail() == null ? "" : properties.bootstrap().ownerEmail().trim();
    }

    /**
     * Resolves the member behind a verified Google identity, refreshing its name and avatar.
     * Empty when the e-mail was never invited to a library.
     */
    @Transactional
    public Optional<CurrentUser> resolve(String email, String name, String avatarUrl) {
        if (email == null || email.isBlank()) {
            return Optional.empty();
        }
        return users.findByEmailIgnoreCase(email.trim()).flatMap(user -> {
            user.updateProfile(name, avatarUrl);
            // Lot 1: one library per user, the first membership is the active one.
            return members.findByUserIdOrderByLibraryId(user.getId()).stream().findFirst()
                    .map(m -> new CurrentUser(user.getId(), user.getEmail(), m.getLibraryId(), m.getRole(),
                            !adminEmail.isEmpty() && adminEmail.equalsIgnoreCase(user.getEmail())));
        });
    }
}
