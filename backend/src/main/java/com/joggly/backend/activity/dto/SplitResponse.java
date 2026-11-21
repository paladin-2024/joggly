package com.joggly.backend.activity.dto;

public record SplitResponse(int splitNumber, double distanceKm, int durationSeconds, double paceMinPerKm) {
}
