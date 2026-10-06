package com.gdailly.library.util;

public final class Strings {

    private Strings() {
    }

    /** Trimmed value, or null when blank. */
    public static String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
