package com.gdailly.library.entity;

/**
 * What a synchronisation did: METADATA_FILL / METADATA_FETCH resynchronise every book of a library (completing empty
 * fields, or only refreshing the answers of the sources), METADATA_BOOK one book; SERIES_ALL lists again the volumes
 * of every series on request, SERIES_SCHEDULED is the hourly background run, SERIES_ONE one series.
 */
public enum SyncKind {
    METADATA_FILL,
    METADATA_FETCH,
    METADATA_BOOK,
    SERIES_ALL,
    SERIES_SCHEDULED,
    SERIES_ONE
}
