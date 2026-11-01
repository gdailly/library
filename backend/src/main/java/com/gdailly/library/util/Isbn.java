package com.gdailly.library.util;

import java.util.Optional;

/** ISBN normalisation: every ISBN is stored as 13 digits. */
public final class Isbn {

    private Isbn() {
    }

    /**
     * Normalises an ISBN-10 or ISBN-13 (spaces and hyphens allowed) to its 13-digit form.
     * Empty when the input is not a valid ISBN (length or check digit).
     */
    public static Optional<String> toIsbn13(String raw) {
        if (raw == null) {
            return Optional.empty();
        }
        String isbn = raw.replaceAll("[\\s-]", "").toUpperCase();
        if (isbn.matches("\\d{13}")) {
            return isbn.charAt(12) == checkDigit13(isbn.substring(0, 12)) ? Optional.of(isbn) : Optional.empty();
        }
        if (isbn.matches("\\d{9}[\\dX]") && isValidIsbn10(isbn)) {
            String body = "978" + isbn.substring(0, 9);
            return Optional.of(body + checkDigit13(body));
        }
        return Optional.empty();
    }

    /** ISBN-10 form of a 978 ISBN-13, which older catalogue records still use; empty otherwise. */
    public static Optional<String> toIsbn10(String isbn13) {
        if (isbn13 == null || !isbn13.matches("978\\d{10}")) {
            return Optional.empty();
        }
        String body = isbn13.substring(3, 12);
        int sum = 0;
        for (int i = 0; i < 9; i++) {
            sum += (body.charAt(i) - '0') * (10 - i);
        }
        int check = (11 - sum % 11) % 11;
        return Optional.of(body + (check == 10 ? "X" : String.valueOf(check)));
    }

    private static char checkDigit13(String twelveDigits) {
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            int digit = twelveDigits.charAt(i) - '0';
            sum += i % 2 == 0 ? digit : digit * 3;
        }
        return (char) ('0' + (10 - sum % 10) % 10);
    }

    private static boolean isValidIsbn10(String isbn) {
        int sum = 0;
        for (int i = 0; i < 10; i++) {
            char c = isbn.charAt(i);
            int value = c == 'X' ? 10 : c - '0';
            if (c == 'X' && i != 9) {
                return false;
            }
            sum += value * (10 - i);
        }
        return sum % 11 == 0;
    }
}
