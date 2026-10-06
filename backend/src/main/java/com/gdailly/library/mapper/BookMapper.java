package com.gdailly.library.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.gdailly.library.dto.BookRequest;
import com.gdailly.library.dto.BookResponse;
import com.gdailly.library.dto.CoverResponse;
import com.gdailly.library.dto.OtherReadingResponse;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.Reading;

@Mapper(config = MappingConfig.class, uses = {CategoryMapper.class, ReadingMapper.class})
public interface BookMapper {

    /**
     * {@code myReading} is the caller's reading of this book and {@code cover} its signed URLs, both may be null;
     * {@code addedByName} is null when the member who added it left.
     */
    @Mapping(target = "id", source = "book.id")
    @Mapping(target = "categories", source = "book.categories")
    @Mapping(target = "myReading", source = "myReading")
    @Mapping(target = "cover", source = "cover")
    @Mapping(target = "addedByName", source = "addedByName")
    @Mapping(target = "otherReadings", source = "otherReadings")
    BookResponse toResponse(Book book, Reading myReading, CoverResponse cover, String addedByName,
            List<OtherReadingResponse> otherReadings);

    /**
     * Copies the editable fields, trimmed, blanks as null; {@code owned} defaults to true.
     * The ISBN, categories and cover are set by the business layer once validated.
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "libraryId", ignore = true)
    @Mapping(target = "isbn13", ignore = true)
    @Mapping(target = "coverKey", ignore = true)
    @Mapping(target = "categories", ignore = true)
    @Mapping(target = "addedBy", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "owned", defaultValue = "true")
    void updateEntity(BookRequest request, @MappingTarget Book book);
}
