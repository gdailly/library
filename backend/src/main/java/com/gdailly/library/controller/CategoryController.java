package com.gdailly.library.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.gdailly.library.business.CategoryService;
import com.gdailly.library.dto.CategoryRequest;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;

@RestController
@Tag(name = "Categories", description = "Catégories de la bibliothèque")
@RequestMapping("/api/categories")
class CategoryController {

    private final CategoryService categories;

    CategoryController(CategoryService categories) {
        this.categories = categories;
    }

    @GetMapping
    List<CategoryResponse> listCategories(CurrentUser user) {
        return categories.list(user);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    CategoryResponse createCategory(CurrentUser user, @Valid @RequestBody CategoryRequest request) {
        return categories.create(user, request);
    }

    @PutMapping("/{id}")
    CategoryResponse updateCategory(CurrentUser user, @PathVariable Long id, @Valid @RequestBody CategoryRequest request) {
        return categories.update(user, id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deleteCategory(CurrentUser user, @PathVariable Long id) {
        categories.delete(user, id);
    }
}
