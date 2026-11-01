package com.gdailly.library.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.gdailly.library.dto.MeResponse;
import com.gdailly.library.entity.AppUser;

@Mapper(config = MappingConfig.class)
public interface UserMapper {

    @Mapping(target = "libraries", source = "libraries")
    @Mapping(target = "admin", source = "admin")
    MeResponse toMeResponse(AppUser user, List<MeResponse.LibrarySummary> libraries, boolean admin);
}
