package com.joggly.backend.activity.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record SaveActivityRequest(
        @NotNull Instant startTime,
        @PositiveOrZero int durationSeconds,
        @DecimalMin("0.0") double distanceKm,
        @PositiveOrZero Integer stepCount,
        @NotEmpty List<RoutePoint> route,
        UUID runEventId) {
}
