import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/providers.dart';
import '../../models/nearby_runner.dart';
import '../../models/profile.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.read(apiClientProvider)));

class ProfileRepository {
  final ApiClient _api;

  ProfileRepository(this._api);

  Future<Profile> me() async => Profile.fromJson(await _api.get('/api/profiles/me'));

  Future<Profile> updateProfile({
    String? bio,
    String? avatarUrl,
    double? paceMinPerKm,
    double? preferredDistanceKm,
    bool? discoverable,
  }) async {
    final body = <String, dynamic>{
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (paceMinPerKm != null) 'paceMinPerKm': paceMinPerKm,
      if (preferredDistanceKm != null) 'preferredDistanceKm': preferredDistanceKm,
      if (discoverable != null) 'discoverable': discoverable,
    };
    return Profile.fromJson(await _api.put('/api/profiles/me', body: body));
  }

  Future<Profile> updateLocation(double latitude, double longitude) async => Profile.fromJson(
        await _api.put('/api/profiles/me/location', body: {'latitude': latitude, 'longitude': longitude}),
      );

  Future<List<NearbyRunner>> nearby({required double lat, required double lng, double radiusKm = 5.0}) async {
    final response = await _api.get('/api/profiles/nearby', query: {'lat': lat, 'lng': lng, 'radiusKm': radiusKm});
    return (response as List).map((e) => NearbyRunner.fromJson(e as Map<String, dynamic>)).toList();
  }
}
