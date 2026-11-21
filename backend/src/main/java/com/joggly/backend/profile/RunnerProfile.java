package com.joggly.backend.profile;

import com.joggly.backend.common.BaseEntity;
import com.joggly.backend.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
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
@Table(name = "runner_profiles")
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class RunnerProfile extends BaseEntity {

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(length = 500)
    private String bio;

    private String avatarUrl;

    /** Comfortable pace, expressed as minutes per kilometre. */
    private Double paceMinPerKm;

    private Double preferredDistanceKm;

    private Double latitude;

    private Double longitude;

    private Instant locationUpdatedAt;

    /** Whether this runner currently wants to be discoverable in "nearby runners" search. */
    @Column(nullable = false)
    private boolean discoverable = true;
}
