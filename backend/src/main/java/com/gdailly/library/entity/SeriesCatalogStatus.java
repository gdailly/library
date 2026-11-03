package com.gdailly.library.entity;

/** Outcome of the last attempt to list the volumes of a series. */
public enum SeriesCatalogStatus {
    /** The BnF listed the series' books. */
    FOUND,
    /** The series record is known but lists no book. */
    NOT_FOUND,
    /** No book of the series links to a BnF series record. */
    NO_REFERENCE
}
