package com.gdailly.library.security;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;

import com.gdailly.library.IntegrationTest;

class AuthenticationIT extends IntegrationTest {

    @Test
    void rejectsRequestWithoutToken() throws Exception {
        mvc.perform(get("/api/me")).andExpect(status().isUnauthorized());
    }

    @Test
    void rejectsGoogleAccountThatIsNotMember() throws Exception {
        mvc.perform(get("/api/me").with(googleUser("stranger@example.com")))
                .andExpect(status().isForbidden());
    }

    @Test
    void returnsProfileOfBootstrapOwner() throws Exception {
        mvc.perform(get("/api/me").with(googleUser("Owner@Example.com")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value(OWNER_EMAIL))
                .andExpect(jsonPath("$.name").value("Test Owner@Example.com"))
                .andExpect(jsonPath("$.libraries[0].name").value("Ma bibliothèque"))
                .andExpect(jsonPath("$.libraries[0].role").value("OWNER"));
    }

    @Test
    void healthIsPublic() throws Exception {
        mvc.perform(get("/actuator/health")).andExpect(status().isOk());
    }
}
