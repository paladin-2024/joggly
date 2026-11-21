package com.joggly.backend.profile.dto;

import java.util.UUID;

public record ProfileResponse(
        UUID userId,
        String displayName,
        String bio,
        String avatarUrl,
        Double paceMinPerKm,
        Double preferredDistanceKm,
        Double latitude,
        Double longitude,
        boolean discoverable) {
}
