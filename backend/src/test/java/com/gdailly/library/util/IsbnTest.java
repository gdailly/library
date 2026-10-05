package com.gdailly.library.util;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

class IsbnTest {

    @ParameterizedTest
    @CsvSource({
            "9782070612758, 9782070612758",
            "978-2-07-061275-8, 9782070612758",
            "2070612759, 9782070612758",
            "2-07-061275-9, 9782070612758",
            "080442957X, 9780804429573",
            "080442957x, 9780804429573",
            "' 978 0 306 40615 7 ', 9780306406157"
    })
    void normalisesToIsbn13(String raw, String expected) {
        assertThat(Isbn.toIsbn13(raw)).contains(expected);
    }

    @ParameterizedTest
    @NullAndEmptySource
    @ValueSource(strings = {"9782070612759", "2070612750", "12345", "97820706127580", "X804429570", "abcdefghij"})
    void rejectsInvalidIsbn(String raw) {
        assertThat(Isbn.toIsbn13(raw)).isEmpty();
    }
}
