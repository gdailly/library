package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.dto.MemberRequest;
import com.gdailly.library.dto.MemberResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.MemberMapperImpl;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.security.CurrentUser;

class MemberServiceTest {

    private static final CurrentUser OWNER = new CurrentUser(1L, "owner@example.com", 10L, Role.OWNER);
    private static final CurrentUser MEMBER = new CurrentUser(2L, "member@example.com", 10L, Role.MEMBER);

    private final LibraryMemberRepository members = mock(LibraryMemberRepository.class);
    private final AppUserRepository users = mock(AppUserRepository.class);
    private final MemberService service = new MemberService(members, users, new MemberMapperImpl());

    @BeforeEach
    void setUp() {
        when(users.save(any())).thenAnswer(call -> withId(call.getArgument(0), 50L));
        when(members.save(any())).thenAnswer(call -> call.getArgument(0));
    }

    @Test
    void invitesNewEmailAsMemberByDefault() {
        when(users.findByEmailIgnoreCase("new@example.com")).thenReturn(Optional.empty());

        MemberResponse response = service.invite(OWNER, new MemberRequest("  new@example.com ", null));

        ArgumentCaptor<LibraryMember> saved = ArgumentCaptor.forClass(LibraryMember.class);
        verify(members).save(saved.capture());
        assertThat(saved.getValue().getLibraryId()).isEqualTo(10L);
        assertThat(saved.getValue().getUserId()).isEqualTo(50L);
        assertThat(response.role()).isEqualTo(Role.MEMBER);
        assertThat(response.email()).isEqualTo("new@example.com");
    }

    @Test
    void invitesExistingAccountWithRequestedRole() {
        AppUser known = withId(new AppUser("known@example.com"), 60L);
        when(users.findByEmailIgnoreCase("known@example.com")).thenReturn(Optional.of(known));

        MemberResponse response = service.invite(OWNER, new MemberRequest("known@example.com", Role.OWNER));

        verify(users, never()).save(any());
        assertThat(response.userId()).isEqualTo(60L);
        assertThat(response.role()).isEqualTo(Role.OWNER);
    }

    @Test
    void refusesInvitingSomeoneAlreadyMember() {
        AppUser known = withId(new AppUser("known@example.com"), 60L);
        when(users.findByEmailIgnoreCase("known@example.com")).thenReturn(Optional.of(known));
        when(members.existsById(new LibraryMember.Key(10L, 60L))).thenReturn(true);

        assertThatThrownBy(() -> service.invite(OWNER, new MemberRequest("known@example.com", null)))
                .isInstanceOf(ConflictException.class);
        verify(members, never()).save(any());
    }

    @Test
    void onlyOwnersInviteOrRemove() {
        assertThatThrownBy(() -> service.invite(MEMBER, new MemberRequest("x@example.com", null)))
                .isInstanceOf(ForbiddenException.class);
        assertThatThrownBy(() -> service.remove(MEMBER, 1L)).isInstanceOf(ForbiddenException.class);
        verifyNoInteractions(users, members);
    }

    @Test
    void removesMember() {
        LibraryMember member = new LibraryMember(10L, 2L, Role.MEMBER);
        when(members.findById(new LibraryMember.Key(10L, 2L))).thenReturn(Optional.of(member));

        service.remove(OWNER, 2L);

        verify(members).delete(member);
    }

    @Test
    void keepsTheLastOwner() {
        LibraryMember owner = new LibraryMember(10L, 1L, Role.OWNER);
        when(members.findById(new LibraryMember.Key(10L, 1L))).thenReturn(Optional.of(owner));
        when(members.countByLibraryIdAndRole(10L, Role.OWNER)).thenReturn(1L);

        assertThatThrownBy(() -> service.remove(OWNER, 1L)).isInstanceOf(ConflictException.class);
        verify(members, never()).delete(any());
    }

    @Test
    void removesAnOwnerWhenAnotherRemains() {
        LibraryMember owner = new LibraryMember(10L, 3L, Role.OWNER);
        when(members.findById(new LibraryMember.Key(10L, 3L))).thenReturn(Optional.of(owner));
        when(members.countByLibraryIdAndRole(10L, Role.OWNER)).thenReturn(2L);

        service.remove(OWNER, 3L);

        verify(members).delete(owner);
    }

    @Test
    void refusesRemovingUnknownMember() {
        when(members.findById(any())).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.remove(OWNER, 99L)).isInstanceOf(NotFoundException.class);
    }

    @Test
    void listsOwnersFirstThenByEmail() {
        when(members.findByLibraryId(10L)).thenReturn(List.of(
                new LibraryMember(10L, 2L, Role.MEMBER),
                new LibraryMember(10L, 3L, Role.MEMBER),
                new LibraryMember(10L, 1L, Role.OWNER)));
        when(users.findAllById(any())).thenReturn(List.of(
                withId(new AppUser("zoe@example.com"), 2L),
                withId(new AppUser("adam@example.com"), 3L),
                withId(new AppUser("owner@example.com"), 1L)));

        assertThat(service.list(OWNER)).extracting(MemberResponse::email)
                .containsExactly("owner@example.com", "adam@example.com", "zoe@example.com");
    }

    private static AppUser withId(AppUser user, long id) {
        ReflectionTestUtils.setField(user, "id", id);
        return user;
    }
}
