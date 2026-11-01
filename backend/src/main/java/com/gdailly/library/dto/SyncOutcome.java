package com.gdailly.library.dto;

/** Result of resynchronising one book; NOT_FOUND when no source knows its ISBN. */
public enum SyncOutcome {
    UPDATED,
    UNCHANGED,
    NOT_FOUND
}
