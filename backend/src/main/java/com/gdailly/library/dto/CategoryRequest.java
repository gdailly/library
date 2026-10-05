package com.gdailly.library.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Body of POST and PUT /api/categories; {@code color} is a hex color such as {@code #1F5E4B}. */
public record CategoryRequest(
        @NotBlank @Size(max = 100) String name,
        @NotNull @Pattern(regexp = "#[0-9A-Fa-f]{6}") String color) {
}
