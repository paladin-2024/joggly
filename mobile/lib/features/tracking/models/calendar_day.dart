class CalendarDay {
  final DateTime date;
  final int count;
  final double distanceKm;

  CalendarDay({required this.date, required this.count, required this.distanceKm});

  factory CalendarDay.fromJson(Map<String, dynamic> json) => CalendarDay(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );
}

class ActivityCalendar {
  final List<CalendarDay> days;
  final int currentStreakDays;
  final int longestStreakDays;

  ActivityCalendar({required this.days, required this.currentStreakDays, required this.longestStreakDays});

  factory ActivityCalendar.fromJson(Map<String, dynamic> json) => ActivityCalendar(
        days: (json['days'] as List).map((e) => CalendarDay.fromJson(e as Map<String, dynamic>)).toList(),
        currentStreakDays: json['currentStreakDays'] as int,
        longestStreakDays: json['longestStreakDays'] as int,
      );
}
