package com.joggly.backend.activity.dto;

import java.time.Instant;
import java.util.UUID;

public record CommentResponse(
        UUID id,
        UUID authorId,
        String authorDisplayName,
        String authorAvatarUrl,
        String body,
        Instant createdAt) {
}
