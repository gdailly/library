package com.gdailly.library.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;

import com.gdailly.library.config.LivreProperties;

class CoverUrlSignerTest {

    private static final String KEY = "a".repeat(64);
    private static final Instant NOW = Instant.parse("2026-10-05T10:00:00Z");

    @Test
    void urlStaysStableWithinADayAndValidAtLeastADay() {
        CoverUrlSigner morning = signer("secret-0123456789", NOW);
        CoverUrlSigner evening = signer("secret-0123456789", NOW.plus(Duration.ofHours(8)));
        CoverUrlSigner.SignedCover signed = morning.sign(42, KEY);

        assertThat(evening.sign(42, KEY)).isEqualTo(signed);
        assertThat(Instant.ofEpochSecond(signed.expires())).isAfter(NOW.plus(Duration.ofHours(24)));
        assertThat(signer("secret-0123456789", NOW.plus(Duration.ofHours(23))).isValid(42, KEY, signed.expires(), signed.signature())).isTrue();
        assertThat(signer("secret-0123456789", NOW.plus(Duration.ofDays(3))).isValid(42, KEY, signed.expires(), signed.signature())).isFalse();
    }

    @Test
    void rejectsOtherBookKeyOrSecret() {
        CoverUrlSigner.SignedCover signed = signer("secret-0123456789", NOW).sign(42, KEY);
        CoverUrlSigner same = signer("secret-0123456789", NOW);

        assertThat(same.isValid(43, KEY, signed.expires(), signed.signature())).isFalse();
        assertThat(same.isValid(42, "b".repeat(64), signed.expires(), signed.signature())).isFalse();
        assertThat(signer("another-secret-0123", NOW).isValid(42, KEY, signed.expires(), signed.signature())).isFalse();
    }

    @Test
    void requiresASecretOfAtLeast16Characters() {
        assertThatThrownBy(() -> signer("", NOW)).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> signer("a".repeat(15), NOW)).isInstanceOf(IllegalStateException.class);
        assertThat(signer("a".repeat(16), NOW).sign(1, KEY)).isNotNull();
    }

    @Test
    void stillValidDuringItsLastSecond() {
        CoverUrlSigner.SignedCover signed = signer("secret-0123456789", NOW).sign(42, KEY);
        Instant expiry = Instant.ofEpochSecond(signed.expires());

        assertThat(signer("secret-0123456789", expiry).isValid(42, KEY, signed.expires(), signed.signature())).isTrue();
        assertThat(signer("secret-0123456789", expiry.plusSeconds(1)).isValid(42, KEY, signed.expires(), signed.signature()))
                .isFalse();
    }

    @Test
    void rejectsMissingParts() {
        CoverUrlSigner signer = signer("secret-0123456789", NOW);
        CoverUrlSigner.SignedCover signed = signer.sign(42, KEY);
        assertThat(signer.isValid(42, null, signed.expires(), signed.signature())).isFalse();
        assertThat(signer.isValid(42, KEY, signed.expires(), null)).isFalse();
    }

    private static CoverUrlSigner signer(String secret, Instant now) {
        LivreProperties properties = new LivreProperties(null, null, null, null,
                new LivreProperties.Covers(null, secret, null, null));
        return new CoverUrlSigner(properties, Clock.fixed(now, ZoneOffset.UTC));
    }
}
