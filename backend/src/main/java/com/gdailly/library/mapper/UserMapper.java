package com.gdailly.library.mapper;

import java.util.List;

import com.gdailly.library.dto.MeResponse;
import com.gdailly.library.entity.AppUser;

public final class UserMapper {

    private UserMapper() {
    }

    public static MeResponse toMeResponse(AppUser user, List<MeResponse.LibrarySummary> libraries) {
        return new MeResponse(user.getId(), user.getEmail(), user.getName(), user.getAvatarUrl(), libraries);
    }
}
