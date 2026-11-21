import 'package:flutter/material.dart';

/// Which asset from assets/illustrations/ to show. Backed by Microsoft's
/// Fluent Emoji 3D set (MIT licensed) — glossy 3D icons/figurines for empty
/// states, onboarding, and celebratory moments, distinct from the flat
/// HugeIcons glyphs used in ordinary UI chrome.
enum IllustrationAsset {
  personRunning('assets/illustrations/person_running.png'),
  trophy('assets/illustrations/trophy.png'),
  medal('assets/illustrations/medal.png'),
  pushpin('assets/illustrations/pushpin.png'),
  partyPopper('assets/illustrations/party_popper.png'),
  handshake('assets/illustrations/handshake.png'),
  compass('assets/illustrations/compass.png'),
  calendar('assets/illustrations/calendar.png'),
  peopleHugging('assets/illustrations/people_hugging.png');

  final String path;
  const IllustrationAsset(this.path);
}

class Illustration extends StatelessWidget {
  final IllustrationAsset asset;
  final double size;

  const Illustration(this.asset, {super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset.path, width: size, height: size);
  }
}
