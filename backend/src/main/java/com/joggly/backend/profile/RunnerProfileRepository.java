package com.joggly.backend.profile;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RunnerProfileRepository extends JpaRepository<RunnerProfile, UUID> {

    Optional<RunnerProfile> findByUserId(UUID userId);

    @Query("""
            select p from RunnerProfile p
            where p.discoverable = true
              and p.user.id <> :excludeUserId
              and p.latitude between :minLat and :maxLat
              and p.longitude between :minLng and :maxLng
            """)
    List<RunnerProfile> findDiscoverableWithinBoundingBox(
            @Param("excludeUserId") UUID excludeUserId,
            @Param("minLat") double minLat,
            @Param("maxLat") double maxLat,
            @Param("minLng") double minLng,
            @Param("maxLng") double maxLng);
}
