package com.joggly.backend.run.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;

public record CreateRunRequest(
        @NotBlank @Size(max = 120) String title,
        @Size(max = 1000) String description,
        @NotNull @Future Instant startTime,
        @NotNull Double startLatitude,
        @NotNull Double startLongitude,
        String startAddress,
        Double distanceKm,
        Double paceMinPerKm,
        @Min(2) @Max(500) int maxParticipants) {
}
