package com.gdailly.library.controller;

import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import com.gdailly.library.IntegrationTest;
import com.jayway.jsonpath.JsonPath;

class MemberControllerIT extends IntegrationTest {

    @Test
    void ownerInvitesAndRemovesMember() throws Exception {
        mvc.perform(get("/api/me").with(googleUser("carol@example.com"))).andExpect(status().isForbidden());

        String body = mvc.perform(post("/api/library/members").with(owner()).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\": \"Carol@Example.com\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email").value("carol@example.com"))
                .andExpect(jsonPath("$.role").value("MEMBER"))
                .andReturn().getResponse().getContentAsString();
        long carolId = ((Number) JsonPath.read(body, "$.userId")).longValue();

        mvc.perform(get("/api/me").with(googleUser("carol@example.com"))).andExpect(status().isOk());
        mvc.perform(get("/api/library/members").with(googleUser("carol@example.com")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].email").value(hasItem(OWNER_EMAIL)));
        mvc.perform(post("/api/library/members").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\": \"carol@example.com\"}")).andExpect(status().isConflict());

        mvc.perform(delete("/api/library/members/{id}", carolId).with(owner())).andExpect(status().isNoContent());
        mvc.perform(get("/api/me").with(googleUser("carol@example.com"))).andExpect(status().isForbidden());
    }

    @Test
    void memberCannotInviteOrRemove() throws Exception {
        var dave = member("dave@example.com");
        mvc.perform(post("/api/library/members").with(dave).contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\": \"eve@example.com\"}")).andExpect(status().isForbidden());
        mvc.perform(delete("/api/library/members/{id}", 1).with(dave)).andExpect(status().isForbidden());
    }

    @Test
    void keepsAtLeastOneOwnerAndValidatesEmail() throws Exception {
        String me = mvc.perform(get("/api/me").with(owner())).andReturn().getResponse().getContentAsString();
        long ownerId = ((Number) JsonPath.read(me, "$.id")).longValue();
        mvc.perform(delete("/api/library/members/{id}", ownerId).with(owner())).andExpect(status().isConflict());
        mvc.perform(post("/api/library/members").with(owner()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\": \"not-an-email\"}")).andExpect(status().isBadRequest());
        mvc.perform(delete("/api/library/members/{id}", 999999).with(owner())).andExpect(status().isNotFound());
    }
}
