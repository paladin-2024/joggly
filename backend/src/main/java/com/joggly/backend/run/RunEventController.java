package com.joggly.backend.run;

import com.joggly.backend.run.dto.CreateRunRequest;
import com.joggly.backend.run.dto.NearbyRunResponse;
import com.joggly.backend.run.dto.RunResponse;
import com.joggly.backend.user.User;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/runs")
@RequiredArgsConstructor
public class RunEventController {

    private final RunEventService runEventService;

    @PostMapping
    public ResponseEntity<RunResponse> create(
            @AuthenticationPrincipal User user, @Valid @RequestBody CreateRunRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(runEventService.create(user, request));
    }

    @GetMapping("/{id}")
    public RunResponse get(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return runEventService.get(id, user);
    }

    @GetMapping("/mine")
    public List<RunResponse> mine(@AuthenticationPrincipal User user) {
        return runEventService.mine(user);
    }

    @GetMapping("/nearby")
    public List<NearbyRunResponse> nearby(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "5.0") double radiusKm) {
        return runEventService.findNearby(lat, lng, radiusKm);
    }

    @PostMapping("/{id}/join")
    public RunResponse join(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return runEventService.join(id, user);
    }

    @PostMapping("/{id}/leave")
    public RunResponse leave(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return runEventService.leave(id, user);
    }
}
