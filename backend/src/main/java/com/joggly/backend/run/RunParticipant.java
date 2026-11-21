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
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@Entity
@Table(name = "run_participants", uniqueConstraints = @UniqueConstraint(columnNames = {"run_event_id", "user_id"}))
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class RunParticipant extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "run_event_id", nullable = false)
    private RunEvent runEvent;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ParticipantStatus status;
}
