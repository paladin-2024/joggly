package com.joggly.backend.leaderboard;

import com.joggly.backend.leaderboard.dto.LeaderboardEntryResponse;
import com.joggly.backend.user.User;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/leaderboard")
@RequiredArgsConstructor
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    @GetMapping("/weekly")
    public List<LeaderboardEntryResponse> weekly(@AuthenticationPrincipal User user) {
        return leaderboardService.weekly(user);
    }
}
