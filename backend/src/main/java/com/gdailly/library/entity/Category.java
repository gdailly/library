package com.gdailly.library.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long libraryId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String color;

    protected Category() {
    }

    public Category(Long libraryId) {
        this.libraryId = libraryId;
    }

    public Long getId() {
        return id;
    }

    public Long getLibraryId() {
        return libraryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}
