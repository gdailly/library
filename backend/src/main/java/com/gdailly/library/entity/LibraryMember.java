package com.gdailly.library.entity;

import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;

@Entity
@IdClass(LibraryMember.Key.class)
public class LibraryMember {

    @Id
    private Long libraryId;

    @Id
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    protected LibraryMember() {
    }

    public LibraryMember(Long libraryId, Long userId, Role role) {
        this.libraryId = libraryId;
        this.userId = userId;
        this.role = role;
    }

    public Long getLibraryId() {
        return libraryId;
    }

    public Long getUserId() {
        return userId;
    }

    public Role getRole() {
        return role;
    }

    public record Key(Long libraryId, Long userId) implements Serializable {
    }
}
