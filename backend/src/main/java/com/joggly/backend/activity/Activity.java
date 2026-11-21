package com.joggly.backend.activity;

import com.joggly.backend.common.BaseEntity;
import com.joggly.backend.run.RunEvent;
import com.joggly.backend.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@Entity
@Table(name = "activities")
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Activity extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Optional: the scheduled run this tracked activity was recorded for, if any. */
    @ManyToOne
    @JoinColumn(name = "run_event_id")
    private RunEvent runEvent;

    @Column(nullable = false)
    private Instant startTime;

    @Column(nullable = false)
    private int durationSeconds;

    @Column(nullable = false)
    private double distanceKm;

    @Column(nullable = false)
    private double averagePaceMinPerKm;

    private Integer stepCount;

    /** JSON-encoded List<RoutePoint>; see ActivityService for (de)serialization. */
    @Column(nullable = false, columnDefinition = "text")
    private String routePointsJson;
}
