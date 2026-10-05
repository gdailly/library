package com.gdailly.library.entity;

import java.time.Instant;
import java.util.Locale;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "app_user")
public class AppUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;

    private String name;

    private String avatarUrl;

    @Column(nullable = false)
    private Instant createdAt;

    protected AppUser() {
    }

    public AppUser(String email) {
        this.email = email.toLowerCase(Locale.ROOT);
        this.createdAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    /** Refreshes the profile from the Google token; returns true when something changed. */
    public boolean updateProfile(String name, String avatarUrl) {
        boolean changed = false;
        if (name != null && !name.equals(this.name)) {
            this.name = name;
            changed = true;
        }
        if (avatarUrl != null && !avatarUrl.equals(this.avatarUrl)) {
            this.avatarUrl = avatarUrl;
            changed = true;
        }
        return changed;
    }
}
