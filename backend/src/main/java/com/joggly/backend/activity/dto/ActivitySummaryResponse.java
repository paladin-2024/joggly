package com.joggly.backend.activity.dto;

import java.time.Instant;
import java.util.UUID;

/** Lighter weight than ActivityResponse: no route points, for list views. */
public record ActivitySummaryResponse(
        UUID id,
        Instant startTime,
        int durationSeconds,
        double distanceKm,
        double averagePaceMinPerKm,
        Integer stepCount) {
}
