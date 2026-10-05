package com.gdailly.library.mapper;

import com.gdailly.library.dto.MemberResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;

public final class MemberMapper {

    private MemberMapper() {
    }

    public static MemberResponse toResponse(LibraryMember member, AppUser user) {
        return new MemberResponse(user.getId(), user.getEmail(), user.getName(), user.getAvatarUrl(), member.getRole());
    }
}
