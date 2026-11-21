import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/calendar_day.dart';

/// A GitHub-contributions-style grid: one square per day, darker for more
/// activity that day. Columns run left (oldest) to right (today).
class ContributionCalendar extends StatelessWidget {
  final List<CalendarDay> days;

  const ContributionCalendar({super.key, required this.days});

  Color _colorFor(int count) {
    if (count <= 0) return AppColors.divider;
    if (count == 1) return AppColors.accent.withValues(alpha: 0.45);
    if (count == 2) return AppColors.accent.withValues(alpha: 0.7);
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Pad to a full column height (7) so the last column renders cleanly.
    final padded = List<CalendarDay?>.from(days);
    while (padded.length % 7 != 0) {
      padded.insert(0, null);
    }

    final columns = <List<CalendarDay?>>[];
    for (var i = 0; i < padded.length; i += 7) {
      columns.add(padded.sublist(i, i + 7));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: columns
            .map(
              (column) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: column
                      .map(
                        (day) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Tooltip(
                            message: day == null
                                ? ''
                                : '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-'
                                    '${day.date.day.toString().padLeft(2, '0')}: '
                                    '${day.count} run${day.count == 1 ? '' : 's'}',
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: day == null ? Colors.transparent : _colorFor(day.count),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
