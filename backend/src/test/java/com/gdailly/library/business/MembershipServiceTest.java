package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.security.CurrentUser;

class MembershipServiceTest {

    private final AppUserRepository users = mock(AppUserRepository.class);
    private final LibraryMemberRepository members = mock(LibraryMemberRepository.class);
    private final MembershipService service = new MembershipService(users, members);

    @Test
    void resolvesFirstLibraryOfInvitedAccountAndRefreshesProfile() {
        AppUser user = new AppUser("alice@example.com");
        ReflectionTestUtils.setField(user, "id", 7L);
        when(users.findByEmailIgnoreCase("alice@example.com")).thenReturn(Optional.of(user));
        when(members.findByUserIdOrderByLibraryId(7L)).thenReturn(List.of(
                new LibraryMember(3L, 7L, Role.OWNER), new LibraryMember(8L, 7L, Role.MEMBER)));

        Optional<CurrentUser> current = service.resolve(" alice@example.com ", "Alice", "https://a.png");

        assertThat(current).contains(new CurrentUser(7L, "alice@example.com", 3L, Role.OWNER));
        assertThat(user.getName()).isEqualTo("Alice");
        assertThat(user.getAvatarUrl()).isEqualTo("https://a.png");
    }

    @Test
    void refusesAccountWithoutLibrary() {
        AppUser user = new AppUser("former@example.com");
        ReflectionTestUtils.setField(user, "id", 9L);
        when(users.findByEmailIgnoreCase("former@example.com")).thenReturn(Optional.of(user));
        when(members.findByUserIdOrderByLibraryId(9L)).thenReturn(List.of());

        assertThat(service.resolve("former@example.com", null, null)).isEmpty();
    }

    @Test
    void refusesUnknownOrMissingEmail() {
        when(users.findByEmailIgnoreCase("stranger@example.com")).thenReturn(Optional.empty());
        assertThat(service.resolve("stranger@example.com", null, null)).isEmpty();

        MembershipService fresh = new MembershipService(mock(AppUserRepository.class), members);
        assertThat(fresh.resolve(null, null, null)).isEmpty();
        assertThat(fresh.resolve(" ", null, null)).isEmpty();
        verifyNoInteractions(members);
    }

    @Test
    void keepsProfileWhenTokenHasNoName() {
        AppUser user = new AppUser("bob@example.com");
        user.updateProfile("Bob", "https://b.png");
        assertThat(user.updateProfile(null, null)).isFalse();
        assertThat(user.updateProfile("Bob", "https://b.png")).isFalse();
        assertThat(user.updateProfile("Robert", null)).isTrue();
        assertThat(user.getName()).isEqualTo("Robert");
        assertThat(user.getAvatarUrl()).isEqualTo("https://b.png");
    }
}
