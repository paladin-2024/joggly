package com.joggly.backend.activity;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import com.joggly.backend.activity.dto.AchievementResponse;
import com.joggly.backend.activity.dto.ActivityResponse;
import com.joggly.backend.activity.dto.ActivitySummaryResponse;
import com.joggly.backend.activity.dto.CalendarDayResponse;
import com.joggly.backend.activity.dto.CalendarResponse;
import com.joggly.backend.activity.dto.CommentRequest;
import com.joggly.backend.activity.dto.CommentResponse;
import com.joggly.backend.activity.dto.ProfileStatsResponse;
import com.joggly.backend.activity.dto.RoutePoint;
import com.joggly.backend.activity.dto.SaveActivityRequest;
import com.joggly.backend.activity.dto.SplitResponse;
import com.joggly.backend.common.GeoUtils;
import com.joggly.backend.common.exception.NotFoundException;
import com.joggly.backend.connection.ConnectionRepository;
import com.joggly.backend.run.RunEvent;
import com.joggly.backend.run.RunEventRepository;
import com.joggly.backend.user.User;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final RunEventRepository runEventRepository;
    private final ActivityKudosRepository kudosRepository;
    private final ActivityCommentRepository commentRepository;
    private final ConnectionRepository connectionRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public ActivityResponse create(User user, SaveActivityRequest request) {
        RunEvent runEvent = request.runEventId() == null
                ? null
                : runEventRepository.findById(request.runEventId())
                        .orElseThrow(() -> new NotFoundException("Run not found: " + request.runEventId()));

        double averagePace = request.distanceKm() > 0
                ? (request.durationSeconds() / 60.0) / request.distanceKm()
                : 0.0;

        Activity activity = Activity.builder()
                .user(user)
                .runEvent(runEvent)
                .startTime(request.startTime())
                .durationSeconds(request.durationSeconds())
                .distanceKm(request.distanceKm())
                .averagePaceMinPerKm(averagePace)
                .stepCount(request.stepCount())
                .routePointsJson(writeRoute(request.route()))
                .build();
        activityRepository.save(activity);

        return toResponse(activity, user);
    }

    @Transactional(readOnly = true)
    public ActivityResponse get(UUID id, User viewer) {
        Activity activity = findViewableActivity(id, viewer);
        return toResponse(activity, viewer);
    }

    @Transactional
    public ActivityResponse toggleKudos(UUID id, User user) {
        Activity activity = findViewableActivity(id, user);
        kudosRepository.findByActivityIdAndUserId(id, user.getId())
                .ifPresentOrElse(
                        kudosRepository::delete,
                        () -> kudosRepository.save(ActivityKudos.builder().activity(activity).user(user).build()));
        return toResponse(activity, user);
    }

    @Transactional(readOnly = true)
    public List<CommentResponse> listComments(UUID id, User viewer) {
        findViewableActivity(id, viewer);
        return commentRepository.findByActivityIdOrderByCreatedAtAsc(id).stream()
                .map(c -> new CommentResponse(
                        c.getId(), c.getUser().getId(), c.getUser().getDisplayName(),
                        c.getUser().getAvatarUrl(), c.getBody(), c.getCreatedAt()))
                .toList();
    }

    @Transactional
    public CommentResponse addComment(UUID id, User user, CommentRequest request) {
        Activity activity = findViewableActivity(id, user);
        ActivityComment comment = ActivityComment.builder()
                .activity(activity)
                .user(user)
                .body(request.body())
                .build();
        commentRepository.save(comment);
        return new CommentResponse(
                comment.getId(), user.getId(), user.getDisplayName(), user.getAvatarUrl(),
                comment.getBody(), comment.getCreatedAt());
    }

    @Transactional(readOnly = true)
    public List<ActivitySummaryResponse> mine(User user) {
        return activityRepository.findByUserIdOrderByStartTimeDesc(user.getId()).stream()
                .map(a -> new ActivitySummaryResponse(
                        a.getId(), a.getStartTime(), a.getDurationSeconds(), a.getDistanceKm(),
                        a.getAveragePaceMinPerKm(), a.getStepCount()))
                .toList();
    }

    @Transactional(readOnly = true)
    public ProfileStatsResponse stats(User user) {
        long total = activityRepository.countByUserId(user.getId());
        double distance = activityRepository.sumDistanceKmByUserId(user.getId());
        return new ProfileStatsResponse(total, distance);
    }

    /**
     * A GitHub-contributions-style grid: one entry per day for the last `weeks` weeks. Streaks
     * are computed from the user's whole history, not just the displayed window, so they match
     * what achievements() reports.
     */
    @Transactional(readOnly = true)
    public CalendarResponse calendar(User user, int weeks) {
        List<Activity> all = activityRepository.findByUserIdOrderByStartTimeDesc(user.getId());

        Map<LocalDate, int[]> countByDay = new HashMap<>();
        Map<LocalDate, Double> distanceByDay = new HashMap<>();
        for (Activity a : all) {
            LocalDate day = a.getStartTime().atZone(ZoneOffset.UTC).toLocalDate();
            countByDay.computeIfAbsent(day, d -> new int[1])[0]++;
            distanceByDay.merge(day, a.getDistanceKm(), Double::sum);
        }

        int[] streaks = computeStreaks(countByDay.keySet());

        LocalDate today = Instant.now().atZone(ZoneOffset.UTC).toLocalDate();
        LocalDate start = today.minusDays((long) weeks * 7 - 1);
        List<CalendarDayResponse> days = new ArrayList<>();
        for (LocalDate d = start; !d.isAfter(today); d = d.plusDays(1)) {
            int count = countByDay.containsKey(d) ? countByDay.get(d)[0] : 0;
            double distance = distanceByDay.getOrDefault(d, 0.0);
            days.add(new CalendarDayResponse(d.toString(), count, distance));
        }

        return new CalendarResponse(days, streaks[0], streaks[1]);
    }

    @Transactional(readOnly = true)
    public List<AchievementResponse> achievements(User user) {
        long totalActivities = activityRepository.countByUserId(user.getId());
        double totalDistanceKm = activityRepository.sumDistanceKmByUserId(user.getId());
        Set<LocalDate> activeDays = activeDays(activityRepository.findByUserIdOrderByStartTimeDesc(user.getId()));
        int longestStreak = computeStreaks(activeDays)[1];

        return List.of(
                new AchievementResponse("FIRST_RUN", "First Run", "Complete your first tracked run", totalActivities >= 1),
                new AchievementResponse("RUNS_5", "Getting Started", "Track 5 runs", totalActivities >= 5),
                new AchievementResponse("RUNS_10", "Habit Builder", "Track 10 runs", totalActivities >= 10),
                new AchievementResponse("DISTANCE_10", "10K Club", "Run a total of 10 km", totalDistanceKm >= 10),
                new AchievementResponse("DISTANCE_50", "50K Club", "Run a total of 50 km", totalDistanceKm >= 50),
                new AchievementResponse("DISTANCE_100", "Century", "Run a total of 100 km", totalDistanceKm >= 100),
                new AchievementResponse("STREAK_3", "On a Roll", "A 3-day running streak", longestStreak >= 3),
                new AchievementResponse("STREAK_7", "Unstoppable", "A 7-day running streak", longestStreak >= 7));
    }

    private Set<LocalDate> activeDays(List<Activity> activities) {
        Set<LocalDate> days = new HashSet<>();
        for (Activity a : activities) {
            days.add(a.getStartTime().atZone(ZoneOffset.UTC).toLocalDate());
        }
        return days;
    }

    /** Returns [currentStreak, longestStreak], both in days, computed from UTC calendar days.
     *  shortcut: a day counts as "active" the moment it has >=1 activity; there's no grace
     *  period, so the current streak reads as 0 until today's first run is saved. */
    private int[] computeStreaks(Set<LocalDate> activeDays) {
        if (activeDays.isEmpty()) return new int[] {0, 0};

        LocalDate today = Instant.now().atZone(ZoneOffset.UTC).toLocalDate();
        LocalDate earliest = activeDays.stream().min(LocalDate::compareTo).orElseThrow();

        int longest = 0;
        int running = 0;
        for (LocalDate d = earliest; !d.isAfter(today); d = d.plusDays(1)) {
            if (activeDays.contains(d)) {
                running++;
                longest = Math.max(longest, running);
            } else {
                running = 0;
            }
        }

        int current = 0;
        for (LocalDate d = today; activeDays.contains(d); d = d.minusDays(1)) {
            current++;
        }

        return new int[] {current, longest};
    }

    /** Visible to its owner, or to anyone with an accepted connection to the owner (feed/kudos/comments). */
    private Activity findViewableActivity(UUID id, User viewer) {
        Activity activity = activityRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity not found: " + id));
        boolean isOwner = activity.getUser().getId().equals(viewer.getId());
        boolean isConnected = !isOwner
                && connectionRepository.existsAcceptedBetween(viewer.getId(), activity.getUser().getId());
        if (!isOwner && !isConnected) {
            throw new NotFoundException("Activity not found: " + id);
        }
        return activity;
    }

    private ActivityResponse toResponse(Activity activity, User viewer) {
        List<RoutePoint> route = readRoute(activity.getRoutePointsJson());
        User owner = activity.getUser();
        return new ActivityResponse(
                activity.getId(),
                owner.getId(),
                owner.getDisplayName(),
                owner.getAvatarUrl(),
                activity.getStartTime(),
                activity.getDurationSeconds(),
                activity.getDistanceKm(),
                activity.getAveragePaceMinPerKm(),
                activity.getStepCount(),
                route,
                computeSplits(route),
                activity.getRunEvent() == null ? null : activity.getRunEvent().getId(),
                kudosRepository.countByActivityId(activity.getId()),
                kudosRepository.findByActivityIdAndUserId(activity.getId(), viewer.getId()).isPresent(),
                commentRepository.countByActivityId(activity.getId()));
    }

    /** Buckets the route into ~1km splits by cumulative distance; the last split may be partial. */
    private List<SplitResponse> computeSplits(List<RoutePoint> route) {
        List<SplitResponse> splits = new ArrayList<>();
        if (route.size() < 2) return splits;

        double cumulativeDistance = 0;
        double splitStartDistance = 0;
        double splitStartTime = route.get(0).elapsedSeconds();
        double nextThreshold = 1.0;
        int splitNumber = 1;

        for (int i = 1; i < route.size(); i++) {
            RoutePoint prev = route.get(i - 1);
            RoutePoint curr = route.get(i);
            cumulativeDistance += GeoUtils.distanceKm(prev.lat(), prev.lng(), curr.lat(), curr.lng());

            while (cumulativeDistance >= nextThreshold) {
                splits.add(new SplitResponse(
                        splitNumber,
                        nextThreshold - splitStartDistance,
                        (int) Math.round(curr.elapsedSeconds() - splitStartTime),
                        paceFor(nextThreshold - splitStartDistance, curr.elapsedSeconds() - splitStartTime)));
                splitStartDistance = nextThreshold;
                splitStartTime = curr.elapsedSeconds();
                nextThreshold += 1.0;
                splitNumber++;
            }
        }

        double remaining = cumulativeDistance - splitStartDistance;
        if (remaining > 0.05) {
            RoutePoint last = route.get(route.size() - 1);
            splits.add(new SplitResponse(
                    splitNumber,
                    remaining,
                    (int) Math.round(last.elapsedSeconds() - splitStartTime),
                    paceFor(remaining, last.elapsedSeconds() - splitStartTime)));
        }

        return splits;
    }

    private double paceFor(double distanceKm, double durationSeconds) {
        return distanceKm > 0 ? (durationSeconds / 60.0) / distanceKm : 0.0;
    }

    private String writeRoute(List<RoutePoint> route) {
        try {
            return objectMapper.writeValueAsString(route);
        } catch (Exception e) {
            throw new IllegalStateException("Could not serialize route", e);
        }
    }

    private List<RoutePoint> readRoute(String json) {
        try {
            return objectMapper.readValue(json, new TypeReference<List<RoutePoint>>() {});
        } catch (Exception e) {
            throw new IllegalStateException("Could not deserialize route", e);
        }
    }
}
