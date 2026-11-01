package com.gdailly.library.dto;

/**
 * FILL completes the empty fields and a missing cover; REPLACE overwrites with what the sources know;
 * FETCH only refreshes the stored answers of the sources, without changing the books.
 */
public enum SyncMode {
    FILL,
    REPLACE,
    FETCH
}
