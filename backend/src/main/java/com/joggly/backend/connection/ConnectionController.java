package com.joggly.backend.connection;

import com.joggly.backend.connection.dto.ConnectionResponse;
import com.joggly.backend.user.User;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/connections")
@RequiredArgsConstructor
public class ConnectionController {

    private final ConnectionService connectionService;

    @PostMapping("/request/{recipientId}")
    public ResponseEntity<ConnectionResponse> request(
            @AuthenticationPrincipal User user, @PathVariable UUID recipientId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(connectionService.request(user, recipientId));
    }

    @PostMapping("/{id}/accept")
    public ConnectionResponse accept(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return connectionService.respond(user, id, true);
    }

    @PostMapping("/{id}/decline")
    public ConnectionResponse decline(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return connectionService.respond(user, id, false);
    }

    @GetMapping
    public List<ConnectionResponse> list(@AuthenticationPrincipal User user) {
        return connectionService.listForUser(user);
    }
}
