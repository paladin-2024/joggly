package com.joggly.backend.leaderboard.dto;

import java.util.UUID;

public record LeaderboardEntryResponse(
        int rank,
        UUID userId,
        String displayName,
        String avatarUrl,
        double totalDistanceKm,
        long totalActivities,
        boolean isMe) {
}
