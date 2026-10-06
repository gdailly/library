package com.gdailly.library.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.UserService;
import com.gdailly.library.dto.MeResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@Tag(name = "Me", description = "Utilisateur connecté")
@RequestMapping("/api/me")
class MeController {

    private final UserService users;

    MeController(UserService users) {
        this.users = users;
    }

    @GetMapping
    MeResponse getMe(CurrentUser currentUser) {
        return users.getProfile(currentUser);
    }
}
