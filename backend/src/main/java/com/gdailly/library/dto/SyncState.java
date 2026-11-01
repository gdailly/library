package com.gdailly.library.dto;

/** State of the full resynchronisation of a library; IDLE when none ran since the server started. */
public enum SyncState {
    IDLE,
    RUNNING,
    DONE
}
