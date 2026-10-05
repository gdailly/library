package com.gdailly.library.business;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.MemberRequest;
import com.gdailly.library.dto.MemberResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.ForbiddenException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.MemberMapper;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.security.CurrentUser;

/** Invitations are by Google e-mail: the account gets access on its first sign-in. Only owners invite or remove. */
@Service
public class MemberService {

    private final LibraryMemberRepository members;
    private final AppUserRepository users;

    MemberService(LibraryMemberRepository members, AppUserRepository users) {
        this.members = members;
        this.users = users;
    }

    @Transactional(readOnly = true)
    public List<MemberResponse> list(CurrentUser user) {
        List<LibraryMember> memberships = members.findByLibraryId(user.libraryId());
        Map<Long, AppUser> byId = users.findAllById(memberships.stream().map(LibraryMember::getUserId).toList()).stream()
                .collect(Collectors.toMap(AppUser::getId, Function.identity()));
        return memberships.stream()
                .map(m -> MemberMapper.toResponse(m, byId.get(m.getUserId())))
                .sorted(Comparator.comparing(MemberResponse::role).thenComparing(MemberResponse::email))
                .toList();
    }

    @Transactional
    public MemberResponse invite(CurrentUser user, MemberRequest request) {
        requireOwner(user);
        String email = request.email().trim();
        AppUser invited = users.findByEmailIgnoreCase(email).orElseGet(() -> users.save(new AppUser(email)));
        if (members.existsById(new LibraryMember.Key(user.libraryId(), invited.getId()))) {
            throw new ConflictException("Cette personne est déjà membre.");
        }
        Role role = request.role() == null ? Role.MEMBER : request.role();
        LibraryMember member = members.save(new LibraryMember(user.libraryId(), invited.getId(), role));
        return MemberMapper.toResponse(member, invited);
    }

    @Transactional
    public void remove(CurrentUser user, Long userId) {
        requireOwner(user);
        LibraryMember member = members.findById(new LibraryMember.Key(user.libraryId(), userId))
                .orElseThrow(NotFoundException::new);
        if (member.getRole() == Role.OWNER && members.countByLibraryIdAndRole(user.libraryId(), Role.OWNER) == 1) {
            throw new ConflictException("La bibliothèque doit garder au moins un propriétaire.");
        }
        members.delete(member);
    }

    private static void requireOwner(CurrentUser user) {
        if (!user.isOwner()) {
            throw new ForbiddenException("Réservé au propriétaire de la bibliothèque.");
        }
    }
}
