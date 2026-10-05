package com.gdailly.library.mapper;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.dto.IsbnLookupResponse;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.entity.Book;

public final class IsbnLookupMapper {

    private IsbnLookupMapper() {
    }

    public static IsbnLookupResponse fromBook(Book book) {
        return new IsbnLookupResponse(book.getIsbn13(), MetadataSource.LIBRARY, book.getId(), book.getTitle(),
                book.getSubtitle(), book.getAuthors(), book.getPublisher(), book.getYear(), book.getPages(),
                book.getLanguage(), book.getSummary(), null);
    }

    public static IsbnLookupResponse fromMetadata(String isbn13, MetadataSource source, BookMetadata metadata) {
        return new IsbnLookupResponse(isbn13, source, null, metadata.title(), metadata.subtitle(), metadata.authors(),
                metadata.publisher(), metadata.year(), metadata.pages(), metadata.language(), metadata.summary(),
                metadata.coverUrl());
    }
}
