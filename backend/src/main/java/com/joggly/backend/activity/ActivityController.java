package com.joggly.backend.activity;

import com.joggly.backend.activity.dto.ActivityResponse;
import com.joggly.backend.activity.dto.ActivitySummaryResponse;
import com.joggly.backend.activity.dto.ProfileStatsResponse;
import com.joggly.backend.activity.dto.SaveActivityRequest;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/activities")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    @PostMapping
    public ResponseEntity<ActivityResponse> create(
            @AuthenticationPrincipal User user, @Valid @RequestBody SaveActivityRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(activityService.create(user, request));
    }

    @GetMapping("/{id}")
    public ActivityResponse get(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return activityService.get(id, user);
    }

    @GetMapping("/mine")
    public List<ActivitySummaryResponse> mine(@AuthenticationPrincipal User user) {
        return activityService.mine(user);
    }

    @GetMapping("/stats")
    public ProfileStatsResponse stats(@AuthenticationPrincipal User user) {
        return activityService.stats(user);
    }
}
