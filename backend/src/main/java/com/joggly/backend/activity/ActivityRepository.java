package com.joggly.backend.activity;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ActivityRepository extends JpaRepository<Activity, UUID> {

    List<Activity> findByUserIdOrderByStartTimeDesc(UUID userId);

    List<Activity> findByUserIdInOrderByStartTimeDesc(Collection<UUID> userIds, Pageable pageable);

    List<Activity> findByUserIdAndStartTimeAfterOrderByStartTimeAsc(UUID userId, Instant since);

    @Query("select count(a) from Activity a where a.user.id = :userId")
    long countByUserId(@Param("userId") UUID userId);

    @Query("select coalesce(sum(a.distanceKm), 0) from Activity a where a.user.id = :userId")
    double sumDistanceKmByUserId(@Param("userId") UUID userId);

    @Query("select count(a) from Activity a where a.user.id = :userId and a.startTime >= :since")
    long countByUserIdSince(@Param("userId") UUID userId, @Param("since") Instant since);

    @Query("select coalesce(sum(a.distanceKm), 0) from Activity a where a.user.id = :userId and a.startTime >= :since")
    double sumDistanceKmByUserIdSince(@Param("userId") UUID userId, @Param("since") Instant since);
}
