package com.joggly.backend.run.dto;

import java.time.Instant;
import java.util.UUID;

public record NearbyRunResponse(
        UUID id,
        String hostDisplayName,
        String title,
        Instant startTime,
        Double startLatitude,
        Double startLongitude,
        String startAddress,
        Double distanceKm,
        Double paceMinPerKm,
        int maxParticipants,
        long joinedCount,
        double distanceFromSearchKm) {
}
