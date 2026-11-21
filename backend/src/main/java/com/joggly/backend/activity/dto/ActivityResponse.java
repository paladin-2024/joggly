package com.joggly.backend.activity.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ActivityResponse(
        UUID id,
        Instant startTime,
        int durationSeconds,
        double distanceKm,
        double averagePaceMinPerKm,
        Integer stepCount,
        List<RoutePoint> route,
        List<SplitResponse> splits,
        UUID runEventId) {
}
