package com.joggly.backend.run.dto;

import com.joggly.backend.run.RunStatus;
import java.time.Instant;
import java.util.UUID;

public record RunResponse(
        UUID id,
        UUID hostId,
        String hostDisplayName,
        String title,
        String description,
        Instant startTime,
        Double startLatitude,
        Double startLongitude,
        String startAddress,
        Double distanceKm,
        Double paceMinPerKm,
        int maxParticipants,
        long joinedCount,
        RunStatus status,
        boolean currentUserJoined) {
}
