package com.miamai.api.leclerc;

import java.util.List;

public record CartHandoffResult(
        boolean success,
        String mode,
        String message,
        List<CartHandoffLine> lines
) {
}
