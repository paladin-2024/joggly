package com.joggly.backend.profile.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(max = 500) String bio,
        String avatarUrl,
        @DecimalMin("2.0") @DecimalMax("15.0") Double paceMinPerKm,
        @DecimalMin("0.5") @DecimalMax("200.0") Double preferredDistanceKm,
        Boolean discoverable) {
}
