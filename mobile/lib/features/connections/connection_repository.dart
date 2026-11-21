import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import 'connection_models.dart';

final connectionRepositoryProvider =
    Provider<ConnectionRepository>((ref) => ConnectionRepository(ref.read(apiClientProvider)));

class ConnectionRepository {
  final ApiClient _api;

  ConnectionRepository(this._api);

  Future<List<Connection>> list() async {
    final response = await _api.get('/api/connections');
    return (response as List).map((e) => Connection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Connection> request(String recipientId) async =>
      Connection.fromJson(await _api.post('/api/connections/request/$recipientId'));

  Future<Connection> accept(String connectionId) async =>
      Connection.fromJson(await _api.post('/api/connections/$connectionId/accept'));

  Future<Connection> decline(String connectionId) async =>
      Connection.fromJson(await _api.post('/api/connections/$connectionId/decline'));
}
