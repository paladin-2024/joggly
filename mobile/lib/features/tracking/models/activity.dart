import 'route_point.dart';
import 'split.dart';

class ActivitySummary {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final double distanceKm;
  final double averagePaceMinPerKm;
  final int? stepCount;

  ActivitySummary({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.averagePaceMinPerKm,
    this.stepCount,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) => ActivitySummary(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        durationSeconds: json['durationSeconds'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        averagePaceMinPerKm: (json['averagePaceMinPerKm'] as num).toDouble(),
        stepCount: json['stepCount'] as int?,
      );
}

class Activity {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final double distanceKm;
  final double averagePaceMinPerKm;
  final int? stepCount;
  final List<RoutePoint> route;
  final List<Split> splits;
  final String? runEventId;

  Activity({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.averagePaceMinPerKm,
    this.stepCount,
    required this.route,
    required this.splits,
    this.runEventId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        durationSeconds: json['durationSeconds'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        averagePaceMinPerKm: (json['averagePaceMinPerKm'] as num).toDouble(),
        stepCount: json['stepCount'] as int?,
        route: (json['route'] as List).map((e) => RoutePoint.fromJson(e as Map<String, dynamic>)).toList(),
        splits: (json['splits'] as List).map((e) => Split.fromJson(e as Map<String, dynamic>)).toList(),
        runEventId: json['runEventId'] as String?,
      );
}
