import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import 'models/leaderboard_entry.dart';

final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((ref) => LeaderboardRepository(ref.read(apiClientProvider)));

class LeaderboardRepository {
  final ApiClient _api;

  LeaderboardRepository(this._api);

  Future<List<LeaderboardEntry>> weekly() async {
    final response = await _api.get('/api/leaderboard/weekly');
    return (response as List).map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
