package com.joggly.backend.activity;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ActivityRepository extends JpaRepository<Activity, UUID> {

    List<Activity> findByUserIdOrderByStartTimeDesc(UUID userId);

    @Query("select count(a) from Activity a where a.user.id = :userId")
    long countByUserId(@Param("userId") UUID userId);

    @Query("select coalesce(sum(a.distanceKm), 0) from Activity a where a.user.id = :userId")
    double sumDistanceKmByUserId(@Param("userId") UUID userId);
}
