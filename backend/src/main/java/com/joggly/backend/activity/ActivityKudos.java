package com.joggly.backend.activity;

import com.joggly.backend.common.BaseEntity;
import com.joggly.backend.user.User;
import jakarta.persistence.Entity;
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
@Table(name = "activity_kudos", uniqueConstraints = @UniqueConstraint(columnNames = {"activity_id", "user_id"}))
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class ActivityKudos extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
