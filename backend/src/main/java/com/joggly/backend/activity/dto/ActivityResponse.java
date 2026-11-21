package com.joggly.backend.activity.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ActivityResponse(
        UUID id,
        UUID ownerId,
        String ownerDisplayName,
        String ownerAvatarUrl,
        Instant startTime,
        int durationSeconds,
        double distanceKm,
        double averagePaceMinPerKm,
        Integer stepCount,
        List<RoutePoint> route,
        List<SplitResponse> splits,
        UUID runEventId,
        long kudosCount,
        boolean kudosGivenByMe,
        long commentCount) {
}
