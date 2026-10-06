package com.gdailly.library.business;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
    private final CategoryMapper categoryMapper;

    CategoryService(CategoryRepository categories, CategoryMapper categoryMapper) {
        this.categories = categories;
        this.categoryMapper = categoryMapper;
    }

    /** Categories by name, with their number of books. */
    @Transactional(readOnly = true)
    public List<CategoryResponse> list(CurrentUser user) {
        Map<Long, Long> counts = categories.countBooksByCategory(user.libraryId()).stream()
                .collect(Collectors.toMap(row -> (Long) row[0], row -> (Long) row[1]));
        return categories.findByLibraryIdOrderByName(user.libraryId()).stream()
                .map(category -> categoryMapper.toResponse(category, counts.getOrDefault(category.getId(), 0L)))
                .toList();
    }

    @Transactional
    public CategoryResponse create(CurrentUser user, CategoryRequest request) {
        if (categories.existsByLibraryIdAndNameIgnoreCase(user.libraryId(), request.name().trim())) {
            throw new ConflictException(DUPLICATE);
        }
        Category category = new Category(user.libraryId());
        categoryMapper.updateEntity(request, category);
        return categoryMapper.toResponse(categories.save(category));
    }

    @Transactional
    public CategoryResponse update(CurrentUser user, Long id, CategoryRequest request) {
        Category category = find(user, id);
        if (categories.existsByLibraryIdAndNameIgnoreCaseAndIdNot(user.libraryId(), request.name().trim(), id)) {
            throw new ConflictException(DUPLICATE);
        }
        categoryMapper.updateEntity(request, category);
        return categoryMapper.toResponse(category);
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
