import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api_client.dart';
import '../../core/env.dart';
import '../../core/providers.dart';
import '../../core/token_storage.dart';
import '../../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiClientProvider), ref.read(tokenStorageProvider)),
);

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  AuthRepository(this._api, this._tokenStorage);

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: googleServerClientId.isEmpty ? null : googleServerClientId,
    );
    _googleSignInInitialized = true;
  }

  Future<AuthenticatedUser> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final String? idToken = account.authentication.idToken;
    if (idToken == null) {
      throw ApiException(0, 'Google did not return an ID token');
    }

    final response = await _api.post('/api/auth/google', body: {'idToken': idToken}, authorized: false);
    await _tokenStorage.save(response['token'] as String);
    return AuthenticatedUser.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthenticatedUser?> restoreSession() async {
    try {
      final token = await _tokenStorage.read();
      if (token == null) return null;
      final response = await _api.get('/api/users/me');
      return AuthenticatedUser.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Treat a broken read (secure storage unavailable, an expired/invalid stored token, a
      // network hiccup) the same as "no session" rather than leaving the app stuck loading.
      try {
        await _tokenStorage.clear();
      } catch (_) {
        // best-effort: storage is already known to be unreliable here
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _tokenStorage.clear();
    try {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // best-effort: local session is already cleared regardless
    }
  }
}
