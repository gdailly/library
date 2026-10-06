package com.gdailly.library.business;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.gdailly.library.dto.CategoryRequest;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.entity.Category;
import com.gdailly.library.entity.Role;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.CategoryMapperImpl;
import com.gdailly.library.repository.CategoryRepository;
import com.gdailly.library.security.CurrentUser;

class CategoryServiceTest {

    private static final CurrentUser USER = new CurrentUser(7L, "alice@example.com", 1L, Role.MEMBER);

    private final CategoryRepository categories = mock(CategoryRepository.class);
    private final CategoryService service = new CategoryService(categories, new CategoryMapperImpl());

    @Test
    void createsCategoryWithTrimmedNameAndUpperCaseColor() {
        when(categories.save(any())).thenAnswer(call -> call.getArgument(0));

        CategoryResponse response = service.create(USER, new CategoryRequest("  Poésie ", "#1f5e4b"));

        assertThat(response.name()).isEqualTo("Poésie");
        assertThat(response.color()).isEqualTo("#1F5E4B");
        verify(categories).existsByLibraryIdAndNameIgnoreCase(1L, "Poésie");
    }

    @Test
    void refusesDuplicateName() {
        when(categories.existsByLibraryIdAndNameIgnoreCase(1L, "Poésie")).thenReturn(true);

        assertThatThrownBy(() -> service.create(USER, new CategoryRequest("Poésie", "#000000")))
                .isInstanceOf(ConflictException.class);
        verify(categories, never()).save(any());
    }

    @Test
    void renamesUnlessAnotherCategoryHasTheName() {
        Category category = new Category(1L);
        ReflectionTestUtils.setField(category, "id", 3L);
        when(categories.findByIdAndLibraryId(3L, 1L)).thenReturn(Optional.of(category));

        assertThat(service.update(USER, 3L, new CategoryRequest("Poèmes", "#d99a2b")).name()).isEqualTo("Poèmes");

        when(categories.existsByLibraryIdAndNameIgnoreCaseAndIdNot(1L, "Romans", 3L)).thenReturn(true);
        assertThatThrownBy(() -> service.update(USER, 3L, new CategoryRequest("Romans", "#d99a2b")))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void ignoresCategoriesOfOtherLibraries() {
        when(categories.findByIdAndLibraryId(3L, 1L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.delete(USER, 3L)).isInstanceOf(NotFoundException.class);
    }
}
