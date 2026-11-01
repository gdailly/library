package com.gdailly.library.entity;

/** Source of a cached ISBN lookup: the source of its title when several answered, or NOT_FOUND. */
public enum LookupSource {
    OPEN_LIBRARY,
    GOOGLE_BOOKS,
    BNF,
    NOT_FOUND
}
