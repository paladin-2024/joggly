package com.joggly.backend.activity;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActivityCommentRepository extends JpaRepository<ActivityComment, UUID> {

    List<ActivityComment> findByActivityIdOrderByCreatedAtAsc(UUID activityId);

    long countByActivityId(UUID activityId);
}
