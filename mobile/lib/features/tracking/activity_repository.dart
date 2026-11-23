import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import 'models/achievement.dart';
import 'models/activity.dart';
import 'models/calendar_day.dart';
import 'models/comment.dart';
import 'models/profile_stats.dart';
import 'models/route_point.dart';

final activityRepositoryProvider =
    Provider<ActivityRepository>((ref) => ActivityRepository(ref.read(apiClientProvider)));

class ActivityRepository {
  final ApiClient _api;

  ActivityRepository(this._api);

  Future<Activity> create({
    required DateTime startTime,
    required int durationSeconds,
    required double distanceKm,
    int? stepCount,
    required List<RoutePoint> route,
    String? runEventId,
  }) async {
    final body = {
      'startTime': startTime.toUtc().toIso8601String(),
      'durationSeconds': durationSeconds,
      'distanceKm': distanceKm,
      'stepCount': stepCount,
      'route': route.map((p) => p.toJson()).toList(),
      'runEventId': runEventId,
    };
    return Activity.fromJson(await _api.post('/api/activities', body: body));
  }

  Future<Activity> get(String id) async => Activity.fromJson(await _api.get('/api/activities/$id'));

  Future<List<ActivitySummary>> mine() async {
    final response = await _api.get('/api/activities/mine');
    return (response as List).map((e) => ActivitySummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProfileStats> stats() async => ProfileStats.fromJson(await _api.get('/api/activities/stats'));

  Future<ActivityCalendar> calendar({int weeks = 12}) async =>
      ActivityCalendar.fromJson(await _api.get('/api/activities/calendar', query: {'weeks': weeks}));

  Future<List<Achievement>> achievements() async {
    final response = await _api.get('/api/activities/achievements');
    return (response as List).map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Activity> toggleKudos(String id) async => Activity.fromJson(await _api.post('/api/activities/$id/kudos'));

  Future<List<Comment>> comments(String id) async {
    final response = await _api.get('/api/activities/$id/comments');
    return (response as List).map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Comment> addComment(String id, String body) async =>
      Comment.fromJson(await _api.post('/api/activities/$id/comments', body: {'body': body}));
}
