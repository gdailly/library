package com.gdailly.library.mapper;

import java.util.Locale;

import com.gdailly.library.dto.CategoryRequest;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.entity.Category;

public final class CategoryMapper {

    private CategoryMapper() {
    }

    public static CategoryResponse toResponse(Category category) {
        return new CategoryResponse(category.getId(), category.getName(), category.getColor());
    }

    public static void updateEntity(Category category, CategoryRequest request) {
        category.setName(request.name().trim());
        category.setColor(request.color().toUpperCase(Locale.ROOT));
    }
}
