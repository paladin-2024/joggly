package com.joggly.backend.activity;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActivityKudosRepository extends JpaRepository<ActivityKudos, UUID> {

    Optional<ActivityKudos> findByActivityIdAndUserId(UUID activityId, UUID userId);

    long countByActivityId(UUID activityId);
}
