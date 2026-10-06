package com.gdailly.library.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.MemberService;
import com.gdailly.library.dto.MemberRequest;
import com.gdailly.library.dto.MemberResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;

@RestController
@Tag(name = "Members", description = "Membres de la bibliothèque")
@RequestMapping("/api/library/members")
class MemberController {

    private final MemberService members;

    MemberController(MemberService members) {
        this.members = members;
    }

    @GetMapping
    List<MemberResponse> listMembers(CurrentUser user) {
        return members.list(user);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    MemberResponse inviteMember(CurrentUser user, @Valid @RequestBody MemberRequest request) {
        return members.invite(user, request);
    }

    @DeleteMapping("/{userId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void removeMember(CurrentUser user, @PathVariable Long userId) {
        members.remove(user, userId);
    }
}
