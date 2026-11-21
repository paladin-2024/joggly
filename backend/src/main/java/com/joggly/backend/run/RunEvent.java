package com.joggly.backend.run;

import com.joggly.backend.common.BaseEntity;
import com.joggly.backend.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
@Table(name = "run_events")
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class RunEvent extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "host_id", nullable = false)
    private User host;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private Instant startTime;

    @Column(nullable = false)
    private Double startLatitude;

    @Column(nullable = false)
    private Double startLongitude;

    private String startAddress;

    private Double distanceKm;

    /** Target pace for the group, expressed as minutes per kilometre. */
    private Double paceMinPerKm;

    @Column(nullable = false)
    private int maxParticipants;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RunStatus status;
}
