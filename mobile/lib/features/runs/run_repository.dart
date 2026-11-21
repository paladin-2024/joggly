import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import '../../models/run_event.dart';

final runRepositoryProvider = Provider<RunRepository>((ref) => RunRepository(ref.read(apiClientProvider)));

class RunRepository {
  final ApiClient _api;

  RunRepository(this._api);

  Future<List<NearbyRunEvent>> nearby({required double lat, required double lng, double radiusKm = 5.0}) async {
    final response = await _api.get('/api/runs/nearby', query: {'lat': lat, 'lng': lng, 'radiusKm': radiusKm});
    return (response as List).map((e) => NearbyRunEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RunEvent>> mine() async {
    final response = await _api.get('/api/runs/mine');
    return (response as List).map((e) => RunEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RunEvent> get(String id) async => RunEvent.fromJson(await _api.get('/api/runs/$id'));

  Future<RunEvent> create({
    required String title,
    String? description,
    required DateTime startTime,
    required double startLatitude,
    required double startLongitude,
    String? startAddress,
    double? distanceKm,
    double? paceMinPerKm,
    required int maxParticipants,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'startAddress': startAddress,
      'distanceKm': distanceKm,
      'paceMinPerKm': paceMinPerKm,
      'maxParticipants': maxParticipants,
    };
    return RunEvent.fromJson(await _api.post('/api/runs', body: body));
  }

  Future<RunEvent> join(String id) async => RunEvent.fromJson(await _api.post('/api/runs/$id/join'));

  Future<RunEvent> leave(String id) async => RunEvent.fromJson(await _api.post('/api/runs/$id/leave'));
}
