package com.gdailly.library.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.dto.IsbnLookupResponse;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.entity.Book;

@Mapper(config = MappingConfig.class)
public interface IsbnLookupMapper {

    /** A book already in the library: no external cover URL, its own cover is served by the API. */
    @Mapping(target = "source", constant = "LIBRARY")
    @Mapping(target = "existingBookId", source = "id")
    @Mapping(target = "coverUrl", ignore = true)
    IsbnLookupResponse fromBook(Book book);

    @Mapping(target = "isbn13", source = "isbn13")
    @Mapping(target = "source", source = "source")
    @Mapping(target = "existingBookId", ignore = true)
    IsbnLookupResponse fromMetadata(String isbn13, MetadataSource source, BookMetadata metadata);
}
