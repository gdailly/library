package com.gdailly.library.dto;

import java.util.List;

import org.jspecify.annotations.Nullable;

/**
 * A series of the library and how complete it is. Volume numbers go from 1 to {@code lastNumber}, the highest known:
 * {@code missingNumbers} are those the library does not own (wished ones included, also listed in
 * {@code wishedNumbers}). {@code unnumbered} counts the books of the series without a volume number.
 * {@code cover} is the cover of its first volume that has one.
 */
public record SeriesResponse(
        String name,
        int books,
        int owned,
        List<Integer> ownedNumbers,
        List<Integer> wishedNumbers,
        List<Integer> missingNumbers,
        @Nullable Integer lastNumber,
        int unnumbered,
        @Nullable CoverResponse cover) {
}
