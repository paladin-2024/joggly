package com.joggly.backend.user.dto;

import java.util.UUID;

public record UserSummaryResponse(UUID userId, String email, String displayName, String avatarUrl) {
}
