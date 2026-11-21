package com.joggly.backend.run;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RunParticipantRepository extends JpaRepository<RunParticipant, UUID> {

    Optional<RunParticipant> findByRunEventIdAndUserId(UUID runEventId, UUID userId);

    long countByRunEventIdAndStatus(UUID runEventId, ParticipantStatus status);
}
