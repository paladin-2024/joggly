package com.joggly.backend.connection;

import com.joggly.backend.common.exception.ConflictException;
import com.joggly.backend.common.exception.NotFoundException;
import com.joggly.backend.connection.dto.ConnectionResponse;
import com.joggly.backend.user.User;
import com.joggly.backend.user.UserRepository;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ConnectionService {

    private final ConnectionRepository connectionRepository;
    private final UserRepository userRepository;

    @Transactional
    public ConnectionResponse request(User requester, UUID recipientId) {
        if (requester.getId().equals(recipientId)) {
            throw new ConflictException("You can't connect with yourself");
        }
        User recipient = userRepository.findById(recipientId)
                .orElseThrow(() -> new NotFoundException("User not found: " + recipientId));

        connectionRepository.findBetween(requester.getId(), recipientId).ifPresent(existing -> {
            throw new ConflictException("A connection already exists with this runner");
        });

        Connection connection = Connection.builder()
                .requester(requester)
                .recipient(recipient)
                .status(ConnectionStatus.PENDING)
                .build();
        try {
            // uq_connections_pair (see V1__init.sql) is the real guard against two
            // near-simultaneous requests between the same two people; the findBetween check
            // above is just the fast path that avoids hitting the database in the common case.
            connectionRepository.save(connection);
        } catch (DataIntegrityViolationException e) {
            throw new ConflictException("A connection already exists with this runner");
        }
        return toResponse(connection);
    }

    @Transactional
    public ConnectionResponse respond(User currentUser, UUID connectionId, boolean accept) {
        Connection connection = connectionRepository.findById(connectionId)
                .orElseThrow(() -> new NotFoundException("Connection not found: " + connectionId));
        if (!connection.getRecipient().getId().equals(currentUser.getId())) {
            throw new ConflictException("Only the recipient can respond to this request");
        }
        connection.setStatus(accept ? ConnectionStatus.ACCEPTED : ConnectionStatus.DECLINED);
        connectionRepository.save(connection);
        return toResponse(connection);
    }

    @Transactional(readOnly = true)
    public List<ConnectionResponse> listForUser(User user) {
        return connectionRepository.findAllForUser(user.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    private ConnectionResponse toResponse(Connection connection) {
        return new ConnectionResponse(
                connection.getId(),
                connection.getRequester().getId(),
                connection.getRequester().getDisplayName(),
                connection.getRecipient().getId(),
                connection.getRecipient().getDisplayName(),
                connection.getStatus());
    }
}
