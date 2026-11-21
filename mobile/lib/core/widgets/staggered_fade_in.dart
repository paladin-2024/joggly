import 'package:flutter/material.dart';

import '../theme.dart';

/// Joggly's one authored entrance motion, reused everywhere a list of cards
/// appears (nearby runs, nearby runners, connections, my runs) instead of a
/// scattered, different effect per screen. Exponential ease-out, staggered
/// by [index] so a list reads as one cascade rather than a simultaneous pop.
class StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredFadeIn({super.key, required this.index, required this.child});

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.standard);
    final curved = CurvedAnimation(parent: _controller, curve: AppMotion.curve);
    _fade = curved;
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved);

    final delay = Duration(milliseconds: 35 * widget.index.clamp(0, 8));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
