package com.gdailly.library.config;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.function.Consumer;

import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jwt.Jwt;

class GoogleIdTokenValidatorTest {

    private final OAuth2TokenValidator<Jwt> validator = SecurityConfig.googleIdTokenValidator(Set.of("web-client", "android-client"));

    @Test
    void acceptsValidGoogleToken() {
        assertThat(validator.validate(token(b -> { })).hasErrors()).isFalse();
        assertThat(validator.validate(token(b -> b.issuer("accounts.google.com"))).hasErrors()).isFalse();
        assertThat(validator.validate(token(b -> b.audience(List.of("android-client")))).hasErrors()).isFalse();
    }

    @Test
    void rejectsForeignAudience() {
        assertThat(validator.validate(token(b -> b.audience(List.of("someone-else")))).hasErrors()).isTrue();
    }

    @Test
    void rejectsForeignIssuer() {
        assertThat(validator.validate(token(b -> b.issuer("https://evil.example.com"))).hasErrors()).isTrue();
    }

    @Test
    void rejectsUnverifiedEmail() {
        assertThat(validator.validate(token(b -> b.claim("email_verified", false))).hasErrors()).isTrue();
    }

    @Test
    void rejectsExpiredToken() {
        Instant past = Instant.now().minusSeconds(3600);
        assertThat(validator.validate(token(b -> b.issuedAt(past.minusSeconds(3600)).expiresAt(past))).hasErrors()).isTrue();
    }

    @Test
    void rejectsEverythingWhenNoClientIdConfigured() {
        OAuth2TokenValidator<Jwt> unconfigured = SecurityConfig.googleIdTokenValidator(Set.of());
        assertThat(unconfigured.validate(token(b -> { })).hasErrors()).isTrue();
    }

    private static Jwt token(Consumer<Jwt.Builder> customizer) {
        Instant now = Instant.now();
        Jwt.Builder builder = Jwt.withTokenValue("token")
                .header("alg", "RS256")
                .issuer("https://accounts.google.com")
                .audience(List.of("web-client"))
                .subject("123")
                .issuedAt(now)
                .expiresAt(now.plusSeconds(3600))
                .claim("email", "someone@example.com")
                .claim("email_verified", true);
        customizer.accept(builder);
        return builder.build();
    }
}
