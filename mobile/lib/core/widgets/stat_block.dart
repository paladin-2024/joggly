import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

/// Icon + big value + small label, used everywhere a run/activity's key numbers
/// (distance, pace, duration, steps, participants) are shown as a stat row.
class StatBlock extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String value;
  final String unit;

  const StatBlock({super.key, required this.icon, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          HugeIcon(icon: icon, color: AppColors.accent, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
          ),
          Text(unit, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
