package com.joggly.backend.feed.dto;

import java.time.Instant;
import java.util.UUID;

public record FeedItemResponse(
        UUID activityId,
        UUID ownerId,
        String ownerDisplayName,
        String ownerAvatarUrl,
        Instant startTime,
        int durationSeconds,
        double distanceKm,
        double averagePaceMinPerKm,
        Integer stepCount,
        long kudosCount,
        boolean kudosGivenByMe,
        long commentCount) {
}
