package com.miamai.api.assistant;

import jakarta.validation.constraints.NotBlank;

public record ChatRequest(
        String sessionId,
        @NotBlank String message
) {
}
