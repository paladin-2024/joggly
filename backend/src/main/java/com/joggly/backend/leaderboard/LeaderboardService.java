package com.joggly.backend.leaderboard;

import com.joggly.backend.activity.ActivityRepository;
import com.joggly.backend.connection.ConnectionRepository;
import com.joggly.backend.leaderboard.dto.LeaderboardEntryResponse;
import com.joggly.backend.user.User;
import com.joggly.backend.user.UserRepository;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Ranks the current user and their accepted connections by distance run in the last 7 days. */
@Service
@RequiredArgsConstructor
public class LeaderboardService {

    private final ConnectionRepository connectionRepository;
    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> weekly(User user) {
        Instant since = Instant.now().minus(7, ChronoUnit.DAYS);

        List<UUID> userIds = new ArrayList<>(connectionRepository.findAcceptedConnectionUserIds(user.getId()));
        userIds.add(user.getId());

        record Candidate(User user, double distanceKm, long activityCount) {}

        List<Candidate> candidates = userRepository.findAllById(userIds).stream()
                .map(u -> new Candidate(
                        u,
                        activityRepository.sumDistanceKmByUserIdSince(u.getId(), since),
                        activityRepository.countByUserIdSince(u.getId(), since)))
                .sorted(Comparator.comparingDouble(Candidate::distanceKm).reversed())
                .toList();

        List<LeaderboardEntryResponse> result = new ArrayList<>();
        for (int i = 0; i < candidates.size(); i++) {
            Candidate c = candidates.get(i);
            result.add(new LeaderboardEntryResponse(
                    i + 1,
                    c.user().getId(),
                    c.user().getDisplayName(),
                    c.user().getAvatarUrl(),
                    c.distanceKm(),
                    c.activityCount(),
                    c.user().getId().equals(user.getId())));
        }
        return result;
    }
}
