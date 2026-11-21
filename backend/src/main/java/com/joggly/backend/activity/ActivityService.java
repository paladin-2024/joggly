package com.joggly.backend.activity;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.joggly.backend.activity.dto.ActivityResponse;
import com.joggly.backend.activity.dto.ActivitySummaryResponse;
import com.joggly.backend.activity.dto.ProfileStatsResponse;
import com.joggly.backend.activity.dto.RoutePoint;
import com.joggly.backend.activity.dto.SaveActivityRequest;
import com.joggly.backend.activity.dto.SplitResponse;
import com.joggly.backend.common.GeoUtils;
import com.joggly.backend.common.exception.NotFoundException;
import com.joggly.backend.run.RunEvent;
import com.joggly.backend.run.RunEventRepository;
import com.joggly.backend.user.User;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final RunEventRepository runEventRepository;
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

        return toResponse(activity);
    }

    @Transactional(readOnly = true)
    public ActivityResponse get(UUID id, User user) {
        Activity activity = findOwnedActivity(id, user);
        return toResponse(activity);
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

    private Activity findOwnedActivity(UUID id, User user) {
        Activity activity = activityRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Activity not found: " + id));
        if (!activity.getUser().getId().equals(user.getId())) {
            throw new NotFoundException("Activity not found: " + id);
        }
        return activity;
    }

    private ActivityResponse toResponse(Activity activity) {
        List<RoutePoint> route = readRoute(activity.getRoutePointsJson());
        return new ActivityResponse(
                activity.getId(),
                activity.getStartTime(),
                activity.getDurationSeconds(),
                activity.getDistanceKm(),
                activity.getAveragePaceMinPerKm(),
                activity.getStepCount(),
                route,
                computeSplits(route),
                activity.getRunEvent() == null ? null : activity.getRunEvent().getId());
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
