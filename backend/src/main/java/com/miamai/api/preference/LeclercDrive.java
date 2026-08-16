package com.miamai.api.preference;

import jakarta.validation.constraints.NotBlank;

public record LeclercDrive(
        @NotBlank String id,
        @NotBlank String name,
        @NotBlank String address
) {
}
