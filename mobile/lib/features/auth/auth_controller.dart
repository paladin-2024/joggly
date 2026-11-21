import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/user.dart';
import 'auth_repository.dart';

class AuthState {
  final bool loading;
  final AuthenticatedUser? user;
  final String? error;

  const AuthState({required this.loading, this.user, this.error});

  AuthState copyWith({bool? loading, AuthenticatedUser? user, String? error}) =>
      AuthState(loading: loading ?? this.loading, user: user ?? this.user, error: error);
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.read(apiClientProvider).onUnauthorized = _handleSessionExpired;
    _restoreSession();
    return const AuthState(loading: true);
  }

  void _handleSessionExpired() {
    if (state.user != null) signOut();
  }

  Future<void> _restoreSession() async {
    final user = await ref.read(authRepositoryProvider).restoreSession();
    state = AuthState(loading: false, user: user);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      state = AuthState(loading: false, user: user);
    } catch (e) {
      state = AuthState(loading: false, user: null, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState(loading: false, user: null);
  }
}
