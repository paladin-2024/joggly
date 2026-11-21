package com.joggly.backend.feed;

import com.joggly.backend.activity.Activity;
import com.joggly.backend.activity.ActivityCommentRepository;
import com.joggly.backend.activity.ActivityKudosRepository;
import com.joggly.backend.activity.ActivityRepository;
import com.joggly.backend.connection.ConnectionRepository;
import com.joggly.backend.feed.dto.FeedItemResponse;
import com.joggly.backend.user.User;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FeedService {

    private static final int FEED_SIZE = 30;

    private final ConnectionRepository connectionRepository;
    private final ActivityRepository activityRepository;
    private final ActivityKudosRepository kudosRepository;
    private final ActivityCommentRepository commentRepository;

    @Transactional(readOnly = true)
    public List<FeedItemResponse> feed(User user) {
        List<UUID> userIds = new ArrayList<>(connectionRepository.findAcceptedConnectionUserIds(user.getId()));
        userIds.add(user.getId());

        List<Activity> activities = activityRepository.findByUserIdInOrderByStartTimeDesc(
                userIds, PageRequest.of(0, FEED_SIZE));

        return activities.stream()
                .map(a -> new FeedItemResponse(
                        a.getId(),
                        a.getUser().getId(),
                        a.getUser().getDisplayName(),
                        a.getUser().getAvatarUrl(),
                        a.getStartTime(),
                        a.getDurationSeconds(),
                        a.getDistanceKm(),
                        a.getAveragePaceMinPerKm(),
                        a.getStepCount(),
                        kudosRepository.countByActivityId(a.getId()),
                        kudosRepository.findByActivityIdAndUserId(a.getId(), user.getId()).isPresent(),
                        commentRepository.countByActivityId(a.getId())))
                .toList();
    }
}
