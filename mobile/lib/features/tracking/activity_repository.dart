import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import 'models/activity.dart';
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
}
