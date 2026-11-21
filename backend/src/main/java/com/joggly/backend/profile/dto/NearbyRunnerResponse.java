package com.joggly.backend.profile.dto;

import java.util.UUID;

/**
 * approxLatitude/approxLongitude are snapped to a coarse grid (see GeoUtils#snapToPrivacyGrid)
 * so a runner's marker can be shown on a map without exposing their exact GPS fix.
 */
public record NearbyRunnerResponse(
        UUID userId,
        String displayName,
        String bio,
        String avatarUrl,
        Double paceMinPerKm,
        Double preferredDistanceKm,
        double distanceKm,
        double approxLatitude,
        double approxLongitude) {
}
