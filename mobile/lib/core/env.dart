/// Backend API base URL.
///
/// 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
/// Override with --dart-define=API_BASE_URL=... for a real device or deployed backend.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

/// Google OAuth web/server client ID used as the `serverClientId` for
/// Google Sign-In, so the backend can verify the ID token's audience.
/// Must match one of `joggly.google.client-ids` on the backend.
const googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: '',
);
