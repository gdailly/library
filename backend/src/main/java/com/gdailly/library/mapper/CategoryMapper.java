package com.gdailly.library.mapper;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.gdailly.library.dto.CategoryRequest;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.entity.Category;

@Mapper(config = MappingConfig.class, imports = Locale.class)
public interface CategoryMapper {

    /** A category attached to a book, without book count. */
    @Mapping(target = "bookCount", ignore = true)
    CategoryResponse toResponse(Category category);

    @Mapping(target = "bookCount", source = "bookCount")
    CategoryResponse toResponse(Category category, Long bookCount);

    /** Sorted by name, case-insensitive. */
    default List<CategoryResponse> toSortedResponses(Collection<Category> categories) {
        return categories.stream()
                .sorted(Comparator.comparing(Category::getName, String.CASE_INSENSITIVE_ORDER))
                .map(this::toResponse)
                .toList();
    }

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "libraryId", ignore = true)
    @Mapping(target = "color", expression = "java(request.color().toUpperCase(Locale.ROOT))")
    void updateEntity(CategoryRequest request, @MappingTarget Category category);
}
