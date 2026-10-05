package com.gdailly.library.business;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.dto.CategoryRequest;
import com.gdailly.library.dto.CategoryResponse;
import com.gdailly.library.entity.Category;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.mapper.CategoryMapper;
import com.gdailly.library.repository.CategoryRepository;
import com.gdailly.library.security.CurrentUser;

@Service
public class CategoryService {

    private static final String DUPLICATE = "Une catégorie porte déjà ce nom.";

    private final CategoryRepository categories;

    CategoryService(CategoryRepository categories) {
        this.categories = categories;
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> list(CurrentUser user) {
        return categories.findByLibraryIdOrderByName(user.libraryId()).stream().map(CategoryMapper::toResponse).toList();
    }

    @Transactional
    public CategoryResponse create(CurrentUser user, CategoryRequest request) {
        if (categories.existsByLibraryIdAndNameIgnoreCase(user.libraryId(), request.name().trim())) {
            throw new ConflictException(DUPLICATE);
        }
        Category category = new Category(user.libraryId());
        CategoryMapper.updateEntity(category, request);
        return CategoryMapper.toResponse(categories.save(category));
    }

    @Transactional
    public CategoryResponse update(CurrentUser user, Long id, CategoryRequest request) {
        Category category = find(user, id);
        if (categories.existsByLibraryIdAndNameIgnoreCaseAndIdNot(user.libraryId(), request.name().trim(), id)) {
            throw new ConflictException(DUPLICATE);
        }
        CategoryMapper.updateEntity(category, request);
        return CategoryMapper.toResponse(category);
    }

    /** Books keep existing; only their link to this category is removed (ON DELETE CASCADE). */
    @Transactional
    public void delete(CurrentUser user, Long id) {
        categories.delete(find(user, id));
    }

    private Category find(CurrentUser user, Long id) {
        return categories.findByIdAndLibraryId(id, user.libraryId()).orElseThrow(NotFoundException::new);
    }
}
