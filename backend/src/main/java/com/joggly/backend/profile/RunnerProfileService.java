package com.joggly.backend.profile;

import com.joggly.backend.common.GeoUtils;
import com.joggly.backend.profile.dto.NearbyRunnerResponse;
import com.joggly.backend.profile.dto.ProfileResponse;
import com.joggly.backend.profile.dto.UpdateLocationRequest;
import com.joggly.backend.profile.dto.UpdateProfileRequest;
import com.joggly.backend.user.User;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RunnerProfileService {

    private final RunnerProfileRepository profileRepository;

    @Transactional
    public ProfileResponse getOrCreate(User user) {
        RunnerProfile profile = findOrCreate(user);
        return toResponse(profile);
    }

    @Transactional
    public ProfileResponse update(User user, UpdateProfileRequest request) {
        RunnerProfile profile = findOrCreate(user);
        if (request.bio() != null) profile.setBio(request.bio());
        if (request.avatarUrl() != null) profile.setAvatarUrl(request.avatarUrl());
        if (request.paceMinPerKm() != null) profile.setPaceMinPerKm(request.paceMinPerKm());
        if (request.preferredDistanceKm() != null) profile.setPreferredDistanceKm(request.preferredDistanceKm());
        if (request.discoverable() != null) profile.setDiscoverable(request.discoverable());
        profileRepository.save(profile);
        return toResponse(profile);
    }

    @Transactional
    public ProfileResponse updateLocation(User user, UpdateLocationRequest request) {
        RunnerProfile profile = findOrCreate(user);
        profile.setLatitude(request.latitude());
        profile.setLongitude(request.longitude());
        profile.setLocationUpdatedAt(Instant.now());
        profileRepository.save(profile);
        return toResponse(profile);
    }

    @Transactional(readOnly = true)
    public List<NearbyRunnerResponse> findNearby(User user, double lat, double lng, double radiusKm) {
        double clampedRadiusKm = GeoUtils.clampRadiusKm(radiusKm);
        double latDelta = GeoUtils.latDegreesForRadius(clampedRadiusKm);
        double lngDelta = GeoUtils.lngDegreesForRadius(clampedRadiusKm, lat);

        return profileRepository.findDiscoverableWithinBoundingBox(
                        user.getId(), lat - latDelta, lat + latDelta, lng - lngDelta, lng + lngDelta)
                .stream()
                .map(p -> new Object[] {p, GeoUtils.distanceKm(lat, lng, p.getLatitude(), p.getLongitude())})
                .filter(pair -> (double) pair[1] <= clampedRadiusKm)
                .sorted(Comparator.comparingDouble(pair -> (double) pair[1]))
                .map(pair -> {
                    RunnerProfile p = (RunnerProfile) pair[0];
                    double distance = (double) pair[1];
                    return new NearbyRunnerResponse(
                            p.getUser().getId(),
                            p.getUser().getDisplayName(),
                            p.getBio(),
                            p.getAvatarUrl(),
                            p.getPaceMinPerKm(),
                            p.getPreferredDistanceKm(),
                            distance,
                            GeoUtils.snapToPrivacyGrid(p.getLatitude()),
                            GeoUtils.snapToPrivacyGrid(p.getLongitude()));
                })
                .toList();
    }

    private RunnerProfile findOrCreate(User user) {
        return profileRepository.findByUserId(user.getId())
                .orElseGet(() -> profileRepository.save(RunnerProfile.builder().user(user).build()));
    }

    private ProfileResponse toResponse(RunnerProfile profile) {
        return new ProfileResponse(
                profile.getUser().getId(),
                profile.getUser().getDisplayName(),
                profile.getBio(),
                profile.getAvatarUrl(),
                profile.getPaceMinPerKm(),
                profile.getPreferredDistanceKm(),
                profile.getLatitude(),
                profile.getLongitude(),
                profile.isDiscoverable());
    }
}
