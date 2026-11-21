package com.joggly.backend.connection.dto;

import com.joggly.backend.connection.ConnectionStatus;
import java.util.UUID;

public record ConnectionResponse(
        UUID id,
        UUID requesterId,
        String requesterDisplayName,
        UUID recipientId,
        String recipientDisplayName,
        ConnectionStatus status) {
}
