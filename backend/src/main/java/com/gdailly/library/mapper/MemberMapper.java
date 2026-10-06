package com.gdailly.library.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.gdailly.library.dto.MemberResponse;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;

@Mapper(config = MappingConfig.class)
public interface MemberMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "role", source = "member.role")
    MemberResponse toResponse(LibraryMember member, AppUser user);
}
