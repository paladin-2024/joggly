import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:joggly/app.dart';
import 'package:joggly/core/providers.dart';
import 'package:joggly/core/token_storage.dart';

/// In-memory stand-in: the real TokenStorage talks to platform secure storage (e.g. libsecret
/// over D-Bus on Linux), which isn't available in a sandboxed widget test and can hang rather
/// than fail fast.
class _FakeTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> save(String token) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  // google_fonts otherwise tries to fetch fonts over the network at runtime, which never
  // resolves in a sandboxed test run and hangs pumpAndSettle.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('shows the sign-in screen when no session is restored', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStorageProvider.overrideWithValue(_FakeTokenStorage())],
        child: const JogglyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
