package com.joggly.backend.run;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RunEventRepository extends JpaRepository<RunEvent, UUID> {

    /**
     * Locks the run's row for the rest of the transaction, so two concurrent joins can't both
     * read the same joined-count before either commits and overbook the run.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from RunEvent r where r.id = :id")
    Optional<RunEvent> findByIdForUpdate(@Param("id") UUID id);

    @Query("""
            select r from RunEvent r
            where r.status = 'SCHEDULED'
              and r.startTime >= :from
              and r.startLatitude between :minLat and :maxLat
              and r.startLongitude between :minLng and :maxLng
            """)
    List<RunEvent> findUpcomingWithinBoundingBox(
            @Param("from") Instant from,
            @Param("minLat") double minLat,
            @Param("maxLat") double maxLat,
            @Param("minLng") double minLng,
            @Param("maxLng") double maxLng);

    List<RunEvent> findByHostIdOrderByStartTimeDesc(UUID hostId);
}
