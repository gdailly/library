package com.gdailly.library.business;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.MeResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.Library;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.UserMapper;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.repository.LibraryRepository;
import com.gdailly.library.security.CurrentUser;

@Service
public class UserService {

    private final AppUserRepository users;
    private final LibraryRepository libraries;
    private final LibraryMemberRepository members;

    UserService(AppUserRepository users, LibraryRepository libraries, LibraryMemberRepository members) {
        this.users = users;
        this.libraries = libraries;
        this.members = members;
    }

    @Transactional(readOnly = true)
    public MeResponse getProfile(CurrentUser currentUser) {
        AppUser user = users.findById(currentUser.userId()).orElseThrow(NotFoundException::new);
        List<MeResponse.LibrarySummary> memberships = members.findByUserIdOrderByLibraryId(user.getId()).stream()
                .map(m -> new MeResponse.LibrarySummary(m.getLibraryId(),
                        libraries.findById(m.getLibraryId()).map(Library::getName).orElse(null), m.getRole()))
                .toList();
        return UserMapper.toMeResponse(user, memberships);
    }
}
