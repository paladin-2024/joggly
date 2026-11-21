# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

Ships identically on iOS and Android with one shared Material-based design language (user
confirmed: no Cupertino/iOS-native adaptation). Recorded as `android` because that's the native
home of the Material design system this app uses; iOS gets the same screens, not a native
iOS interpretation of them.

## Stack

Flutter mobile app (Android/iOS) talking to a Spring Boot (Java 21) + PostgreSQL backend,
chosen directly by the user at project start, not delegated.

## Users

Runners who want company for a run — both casual/social joggers and more dedicated runners
training toward a pace or distance goal, with no lean toward either group. The situation is:
"I want to run, and I'd rather not run alone (or I want to host/join a group run)."

## Product Purpose

Connect people who go running or jogging so they can run together, in person, AND let anyone
track their own runs (live GPS route, pace, distance, steps) the way a dedicated fitness
tracker would. Both are core, not one bolted onto the other. (Revised: tracking was originally
scoped as secondary; the user explicitly elevated it to a core feature alongside the social
meetup flow.)

## Positioning

Two equally core reasons to open the app: (1) getting two or more real people to the same
place at the same time to run together, and (2) recording your own run with Strava-style
live tracking and a personal activity history. Social discovery no longer "wins" over stats
by default — a solo runner who never connects with anyone is still a fully served user.

## Operating Context

Three core flows:

- **Find nearby runners:** browse/discover other runners nearby by pace and distance
  preference, see approximate distance (not exact location, for privacy), and send a "run
  together" connection request.
- **Scheduled group runs:** host posts a run (time, meeting point, distance, pace, max
  participants); others discover it nearby and join. The host is automatically a participant.
- **Live run tracking (Strava-style):** start a run to record live GPS route, distance, pace,
  elapsed time, and step count; stop to save it as an activity with per-km splits; browse past
  activities as personal history; see aggregate stats (total distance, total runs) on your
  profile. Standalone by default; a tracked activity can optionally be linked to a joined
  scheduled run.

Sign-in is Google-only (no password field anywhere in the product). Location is shown on a
map (Google Maps) rather than as a list.

## Capabilities and Constraints

- Backend never exposes another user's exact GPS coordinates to the client; "nearby runner"
  markers use a coarse, privacy-snapped location, not the real fix.
- "Nearby" search radius is capped server-side (50km) — not a product decision to expose as a
  user-facing limit, just an abuse/performance guard.
- A run has a fixed `maxParticipants`; joining a full run is rejected.
- No in-app chat yet — connection requests and run participation exist, but there's no
  messaging surface. Undecided whether that's in scope later.
- No native iOS-specific interaction patterns (no Cupertino navigation, no iOS-style action
  sheets) — see Platform.
- Live run tracking is foreground-only: GPS route recording and step counting stop if the app
  is backgrounded or the screen locks. Background tracking (foreground service / background
  location) is a real but separate undertaking, not yet built.
- A tracked activity's step count is device-reported ("steps since boot," diffed against a
  baseline captured at run start) and may be unavailable on some phones — the UI must handle
  a null step count, not assume every run has one.

## Brand Commitments

None yet. No existing logo, name lock beyond "Joggly," color, or typography commitment.

## Evidence on Hand

None. No real user content, testimonials, case studies, or press exist yet — this is a
pre-launch build. Future design/copy work must not fabricate any of these.

## Product Principles

1. Social meetup and solo tracking are both the product — don't design either flow as a
   lesser add-on to the other.
2. Default to showing people, places, and routes on a map, not in a list, since location is
   central to both flows.
3. Never leak a real person's exact location — approximate/obscure it even when showing it on
   a map. This applies to other users' positions; a runner's own recorded route is theirs to
   see in full.
4. One Google-authenticated identity, no passwords, no separate account system.
5. Welcoming to both casual and serious runners — don't visually signal "elite athletes only"
   or "beginners only."

## Accessibility & Inclusion

No product-specific accessibility requirement has been established yet.
