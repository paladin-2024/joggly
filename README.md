# Joggly

Connect with other runners nearby and go for a jog together — browse runners near you, or
create/join scheduled group runs.

- `backend/` — Spring Boot (Java 21) + PostgreSQL REST API
- `mobile/` — Flutter app (Android/iOS)

## Backend

Requires a JDK 21 and Maven (the `./mvnw` wrapper is included, no local Maven needed).

1. Start Postgres: `docker compose up -d` (from the repo root)
2. Set the required env vars (or edit `backend/src/main/resources/application.yml` directly):
   - `JOGGLY_JWT_SECRET` — any long random string, used to sign session JWTs
   - `JOGGLY_GOOGLE_CLIENT_IDS` — comma-separated Google OAuth client ID(s) (web/Android/iOS)
     from https://console.cloud.google.com/apis/credentials. The ID token's audience is checked
     against this list.
3. Run it: `cd backend && ./mvnw spring-boot:run`

The API listens on `http://localhost:8080`. All endpoints under `/api/**` except
`/api/auth/google` require `Authorization: Bearer <jwt>`.

### Auth flow

The app never sends a password to this backend — sign-in is Google-only:

1. Mobile app signs the user in with Google Sign-In, gets a Google ID token.
2. App calls `POST /api/auth/google { "idToken": "..." }`.
3. Backend verifies the token against Google's servers, creates the user on first sign-in,
   and returns our own short-lived session JWT for subsequent API calls.

### Key endpoints

- `POST /api/auth/google` — exchange a Google ID token for a session JWT
- `GET /api/users/me` — current user
- `GET/PUT /api/profiles/me`, `PUT /api/profiles/me/location` — runner profile + location
- `GET /api/profiles/nearby?lat=&lng=&radiusKm=` — discoverable runners nearby
- `POST /api/runs`, `GET /api/runs/{id}`, `GET /api/runs/nearby`, `GET /api/runs/mine`,
  `POST /api/runs/{id}/join`, `POST /api/runs/{id}/leave` — scheduled group runs
- `POST /api/connections/request/{userId}`, `/{id}/accept`, `/{id}/decline`, `GET /api/connections`
  — 1:1 "run together" requests between matched runners
- `POST /api/activities`, `GET /api/activities/{id}`, `GET /api/activities/mine`,
  `GET /api/activities/stats` — Strava-style tracked runs (route, pace, splits, steps) and
  personal history/aggregate stats

### Schema

The schema is owned by Flyway (`backend/src/main/resources/db/migration/`), not Hibernate
auto-DDL — `ddl-auto` is `validate`, so a schema change means a new `V<n>__*.sql` migration,
not just editing an entity.

## Mobile

Requires the Flutter SDK (already set up at `~/development/flutter` on this machine).

Before running, you need real Google Maps API keys and a Google OAuth client:

- Maps SDK key (Android): put it in `mobile/android/app/src/main/res/values/strings.xml`
  (replaces `REPLACE_WITH_YOUR_MAPS_ANDROID_API_KEY`)
- Maps SDK key (iOS): put it in `mobile/ios/Runner/AppDelegate.swift`
  (replaces `REPLACE_WITH_YOUR_MAPS_IOS_API_KEY`)
- iOS URL scheme for Google Sign-In: `mobile/ios/Runner/Info.plist`, `CFBundleURLSchemes`
  (replace `REPLACE_WITH_YOUR_IOS_CLIENT_ID` with your iOS client's reversed client ID)
- A **Web**-type OAuth client ID is used as `serverClientId` so the backend can verify the ID
  token's audience — pass it at run time, see below.

Run against a local backend:

```
cd mobile
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

`10.0.2.2` is the Android emulator's alias for your machine's `localhost`; use your machine's
LAN IP for a physical device, or `localhost` for iOS simulator.

Live run tracking also needs, on Android, `ACTIVITY_RECOGNITION` granted at runtime (the app
requests it when you start a run) for step counting; location permission is required for both
the "nearby" map and tracking. Tracking is foreground-only — it stops if the app is backgrounded.

## Git workflow

- `main` is production — never push to it directly.
- `dev` is staging. Work lands there via a branch-per-task PR, not a direct push, except for
  genuinely minor changes.
- No AI attribution footers in commits or PRs for this repo.
