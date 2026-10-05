package com.gdailly.library.security;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.Duration;
import java.util.Base64;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.stereotype.Component;

import com.gdailly.library.config.LivreProperties;

/**
 * Signs cover URLs with HMAC-SHA256 ({@code COVER_URL_SECRET}): an image request cannot carry the Google token on the
 * web. The expiry is rounded so that a URL stays identical, and cacheable by the app, for a whole period.
 */
@Component
public class CoverUrlSigner {

    private static final String ALGORITHM = "HmacSHA256";

    private final SecretKeySpec secret;
    private final Duration ttl;
    private final Clock clock;

    CoverUrlSigner(LivreProperties properties, Clock clock) {
        String urlSecret = properties.covers().urlSecret();
        if (urlSecret == null || urlSecret.length() < 16) {
            throw new IllegalStateException("COVER_URL_SECRET must be set (at least 16 characters)");
        }
        this.secret = new SecretKeySpec(urlSecret.getBytes(StandardCharsets.UTF_8), ALGORITHM);
        this.ttl = properties.covers().urlTtl();
        this.clock = clock;
    }

    public record SignedCover(long expires, String signature) {
    }

    /** Valid for at least the configured TTL and at most twice that. */
    public SignedCover sign(long bookId, String coverKey) {
        long period = ttl.toSeconds();
        long expires = (clock.instant().getEpochSecond() / period + 2) * period;
        return new SignedCover(expires, signature(bookId, coverKey, expires));
    }

    public boolean isValid(long bookId, String coverKey, long expires, String signature) {
        if (signature == null || coverKey == null || expires < clock.instant().getEpochSecond()) {
            return false;
        }
        return MessageDigest.isEqual(signature(bookId, coverKey, expires).getBytes(StandardCharsets.US_ASCII),
                signature.getBytes(StandardCharsets.US_ASCII));
    }

    private String signature(long bookId, String coverKey, long expires) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            mac.init(secret);
            byte[] digest = mac.doFinal((bookId + ":" + coverKey + ":" + expires).getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(digest);
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
