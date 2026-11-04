package com.gdailly.library.entity;

/**
 * What a synchronisation did with one item: a book is UPDATED, UNCHANGED or NOT_FOUND by the sources; a series is
 * FOUND at the BnF, NOT_FOUND there, or has NO_REFERENCE (no volume links to a BnF series record). FAILED: a source
 * could not be reached. Under a series, each volume the BnF lists is ADDED (not listed before), UNCHANGED or REMOVED
 * (listed before, not any more).
 */
public enum SyncItemOutcome {
    UPDATED,
    UNCHANGED,
    FOUND,
    NOT_FOUND,
    NO_REFERENCE,
    FAILED,
    ADDED,
    REMOVED
}
