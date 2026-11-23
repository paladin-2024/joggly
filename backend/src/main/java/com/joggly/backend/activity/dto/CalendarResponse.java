package com.joggly.backend.activity.dto;

import java.util.List;

public record CalendarResponse(List<CalendarDayResponse> days, int currentStreakDays, int longestStreakDays) {
}
