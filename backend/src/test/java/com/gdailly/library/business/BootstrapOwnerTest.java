package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.Library;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.repository.LibraryRepository;

class BootstrapOwnerTest {

    private final LibraryRepository libraries = mock(LibraryRepository.class);
    private final LibraryMemberRepository members = mock(LibraryMemberRepository.class);
    private final AppUserRepository users = mock(AppUserRepository.class);

    @Test
    void createsFirstLibraryAndOwner() {
        when(libraries.save(any())).thenAnswer(call -> withId(call.getArgument(0), 10L));
        when(users.findByEmailIgnoreCase("owner@example.com")).thenReturn(Optional.empty());
        when(users.save(any())).thenAnswer(call -> withId(call.getArgument(0), 1L));

        bootstrap(" owner@example.com ", "Bibliothèque familiale").run(null);

        ArgumentCaptor<Library> library = ArgumentCaptor.forClass(Library.class);
        verify(libraries).save(library.capture());
        assertThat(library.getValue().getName()).isEqualTo("Bibliothèque familiale");
        ArgumentCaptor<LibraryMember> member = ArgumentCaptor.forClass(LibraryMember.class);
        verify(members).save(member.capture());
        assertThat(member.getValue().getLibraryId()).isEqualTo(10L);
        assertThat(member.getValue().getUserId()).isEqualTo(1L);
        assertThat(member.getValue().getRole()).isEqualTo(Role.OWNER);
    }

    @Test
    void usesDefaultNameAndExistingAccount() {
        when(libraries.save(any())).thenAnswer(call -> withId(call.getArgument(0), 10L));
        when(users.findByEmailIgnoreCase("owner@example.com"))
                .thenReturn(Optional.of(withId(new AppUser("owner@example.com"), 5L)));

        bootstrap("owner@example.com", " ").run(null);

        ArgumentCaptor<Library> library = ArgumentCaptor.forClass(Library.class);
        verify(libraries).save(library.capture());
        assertThat(library.getValue().getName()).isEqualTo("Ma bibliothèque");
        verify(users, never()).save(any());
    }

    @Test
    void doesNothingOnceALibraryExists() {
        when(libraries.count()).thenReturn(1L);
        bootstrap("owner@example.com", null).run(null);
        verify(libraries, never()).save(any());
    }

    @Test
    void doesNothingWithoutOwnerEmail() {
        bootstrap(null, null).run(null);
        bootstrap("  ", null).run(null);
        verify(libraries, never()).save(any());
        verify(libraries, never()).count();
    }

    private BootstrapOwner bootstrap(String ownerEmail, String libraryName) {
        LivreProperties properties = new LivreProperties(null,
                new LivreProperties.Bootstrap(ownerEmail, libraryName), null, null, null);
        return new BootstrapOwner(properties, libraries, members, users);
    }

    private static <T> T withId(T entity, long id) {
        ReflectionTestUtils.setField(entity, "id", id);
        return entity;
    }
}
