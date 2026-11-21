import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import 'models/feed_item.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) => FeedRepository(ref.read(apiClientProvider)));

class FeedRepository {
  final ApiClient _api;

  FeedRepository(this._api);

  Future<List<FeedItem>> feed() async {
    final response = await _api.get('/api/feed');
    return (response as List).map((e) => FeedItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
