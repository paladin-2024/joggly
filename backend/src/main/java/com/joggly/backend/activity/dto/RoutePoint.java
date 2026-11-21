package com.joggly.backend.activity.dto;

/** One GPS fix recorded during a tracked run. elapsedSeconds is time since the run started. */
public record RoutePoint(double lat, double lng, double elapsedSeconds) {
}
