package com.joggly.backend.run;

import com.joggly.backend.common.GeoUtils;
import com.joggly.backend.common.exception.ConflictException;
import com.joggly.backend.common.exception.NotFoundException;
import com.joggly.backend.run.dto.CreateRunRequest;
import com.joggly.backend.run.dto.NearbyRunResponse;
import com.joggly.backend.run.dto.RunResponse;
import com.joggly.backend.user.User;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RunEventService {

    private final RunEventRepository runEventRepository;
    private final RunParticipantRepository participantRepository;

    @Transactional
    public RunResponse create(User host, CreateRunRequest request) {
        RunEvent run = RunEvent.builder()
                .host(host)
                .title(request.title())
                .description(request.description())
                .startTime(request.startTime())
                .startLatitude(request.startLatitude())
                .startLongitude(request.startLongitude())
                .startAddress(request.startAddress())
                .distanceKm(request.distanceKm())
                .paceMinPerKm(request.paceMinPerKm())
                .maxParticipants(request.maxParticipants())
                .status(RunStatus.SCHEDULED)
                .build();
        runEventRepository.save(run);

        participantRepository.save(RunParticipant.builder()
                .runEvent(run)
                .user(host)
                .status(ParticipantStatus.JOINED)
                .build());

        return toResponse(run, host);
    }

    @Transactional(readOnly = true)
    public RunResponse get(UUID runId, User currentUser) {
        RunEvent run = findRun(runId);
        return toResponse(run, currentUser);
    }

    @Transactional(readOnly = true)
    public List<RunResponse> mine(User currentUser) {
        return runEventRepository.findByHostIdOrderByStartTimeDesc(currentUser.getId()).stream()
                .map(run -> toResponse(run, currentUser))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<NearbyRunResponse> findNearby(double lat, double lng, double radiusKm) {
        radiusKm = GeoUtils.clampRadiusKm(radiusKm);
        double latDelta = GeoUtils.latDegreesForRadius(radiusKm);
        double lngDelta = GeoUtils.lngDegreesForRadius(radiusKm, lat);

        return runEventRepository.findUpcomingWithinBoundingBox(
                        Instant.now(), lat - latDelta, lat + latDelta, lng - lngDelta, lng + lngDelta)
                .stream()
                .map(run -> new Object[] {
                        run, GeoUtils.distanceKm(lat, lng, run.getStartLatitude(), run.getStartLongitude())})
                .filter(pair -> (double) pair[1] <= radiusKm)
                .sorted(Comparator.comparingDouble(pair -> (double) pair[1]))
                .map(pair -> {
                    RunEvent run = (RunEvent) pair[0];
                    double distance = (double) pair[1];
                    long joinedCount = participantRepository.countByRunEventIdAndStatus(
                            run.getId(), ParticipantStatus.JOINED);
                    return new NearbyRunResponse(
                            run.getId(),
                            run.getHost().getDisplayName(),
                            run.getTitle(),
                            run.getStartTime(),
                            run.getStartLatitude(),
                            run.getStartLongitude(),
                            run.getStartAddress(),
                            run.getDistanceKm(),
                            run.getPaceMinPerKm(),
                            run.getMaxParticipants(),
                            joinedCount,
                            distance);
                })
                .toList();
    }

    @Transactional
    public RunResponse join(UUID runId, User user) {
        // Locks the row so a second concurrent join() can't read the same joined-count before
        // this one commits, which would let two joins both squeeze into the last open spot.
        RunEvent run = runEventRepository.findByIdForUpdate(runId)
                .orElseThrow(() -> new NotFoundException("Run not found: " + runId));
        if (run.getStatus() != RunStatus.SCHEDULED) {
            throw new ConflictException("This run is no longer accepting participants");
        }

        RunParticipant participant = participantRepository.findByRunEventIdAndUserId(runId, user.getId())
                .orElse(null);
        if (participant != null && participant.getStatus() == ParticipantStatus.JOINED) {
            return toResponse(run, user);
        }

        long joinedCount = participantRepository.countByRunEventIdAndStatus(runId, ParticipantStatus.JOINED);
        if (joinedCount >= run.getMaxParticipants()) {
            throw new ConflictException("This run is already full");
        }

        if (participant == null) {
            participant = RunParticipant.builder().runEvent(run).user(user).status(ParticipantStatus.JOINED).build();
        } else {
            participant.setStatus(ParticipantStatus.JOINED);
        }
        participantRepository.save(participant);

        return toResponse(run, user);
    }

    @Transactional
    public RunResponse leave(UUID runId, User user) {
        RunEvent run = findRun(runId);
        participantRepository.findByRunEventIdAndUserId(runId, user.getId()).ifPresent(participant -> {
            participant.setStatus(ParticipantStatus.LEFT);
            participantRepository.save(participant);
        });
        return toResponse(run, user);
    }

    private RunEvent findRun(UUID runId) {
        return runEventRepository.findById(runId)
                .orElseThrow(() -> new NotFoundException("Run not found: " + runId));
    }

    private RunResponse toResponse(RunEvent run, User currentUser) {
        long joinedCount = participantRepository.countByRunEventIdAndStatus(run.getId(), ParticipantStatus.JOINED);
        boolean currentUserJoined = participantRepository
                .findByRunEventIdAndUserId(run.getId(), currentUser.getId())
                .map(p -> p.getStatus() == ParticipantStatus.JOINED)
                .orElse(false);

        return new RunResponse(
                run.getId(),
                run.getHost().getId(),
                run.getHost().getDisplayName(),
                run.getTitle(),
                run.getDescription(),
                run.getStartTime(),
                run.getStartLatitude(),
                run.getStartLongitude(),
                run.getStartAddress(),
                run.getDistanceKm(),
                run.getPaceMinPerKm(),
                run.getMaxParticipants(),
                joinedCount,
                run.getStatus(),
                currentUserJoined);
    }
}
