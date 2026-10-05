package com.gdailly.library.dto;

/** Where ISBN metadata came from; LIBRARY means the book is already in the caller's library. */
public enum MetadataSource {
    LIBRARY,
    OPEN_LIBRARY,
    GOOGLE_BOOKS
}
