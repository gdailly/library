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
import com.gdailly.library.entity.LibraryBook;
import com.gdailly.library.entity.Reading;

@Mapper(config = MappingConfig.class, uses = {CategoryMapper.class, ReadingMapper.class})
public interface BookMapper {

    /**
     * A book as the library sees it; its id is the book's own. {@code myReading} is the caller's reading of this book
     * and {@code cover} its signed URLs, both may be null; {@code addedByName} is null when the member who added it
     * left.
     */
    @Mapping(target = "id", source = "entry.book.id")
    @Mapping(target = "isbn13", source = "entry.book.isbn13")
    @Mapping(target = "title", source = "entry.book.title")
    @Mapping(target = "subtitle", source = "entry.book.subtitle")
    @Mapping(target = "series", source = "entry.book.seriesName")
    @Mapping(target = "seriesNumber", source = "entry.book.seriesNumber")
    @Mapping(target = "authors", source = "entry.book.authors")
    @Mapping(target = "publisher", source = "entry.book.publisher")
    @Mapping(target = "year", source = "entry.book.year")
    @Mapping(target = "pages", source = "entry.book.pages")
    @Mapping(target = "language", source = "entry.book.language")
    @Mapping(target = "summary", source = "entry.book.summary")
    @Mapping(target = "owned", source = "entry.owned")
    @Mapping(target = "addedBy", source = "entry.addedBy")
    @Mapping(target = "createdAt", source = "entry.createdAt")
    @Mapping(target = "categories", source = "entry.categories")
    @Mapping(target = "myReading", source = "myReading")
    @Mapping(target = "cover", source = "cover")
    @Mapping(target = "addedByName", source = "addedByName")
    @Mapping(target = "otherReadings", source = "otherReadings")
    BookResponse toResponse(LibraryBook entry, Reading myReading, CoverResponse cover, String addedByName,
            List<OtherReadingResponse> otherReadings);

    /**
     * Copies the fields describing the book, trimmed, blanks as null. The ISBN, the series and the cover are set by
     * the business layer once validated.
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "isbn13", ignore = true)
    @Mapping(target = "coverKey", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "seriesLinks", ignore = true)
    void updateBook(BookRequest request, @MappingTarget Book book);
}
