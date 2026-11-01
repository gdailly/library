package com.gdailly.library.dto;

/**
 * Where ISBN metadata came from; LIBRARY means the book is already in the caller's library.
 * When several sources answered, the source of the title.
 */
public enum MetadataSource {
    LIBRARY,
    OPEN_LIBRARY,
    GOOGLE_BOOKS,
    BNF
}
