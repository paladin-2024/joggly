import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/calendar_day.dart';

/// A GitHub-contributions-style grid: one square per day, darker for more
/// activity that day. Columns run left (oldest) to right (today). Fills the
/// full available width rather than a fixed cell size, and rings today's
/// cell so the grid always has a clear anchor to read from.
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

    const gap = 4.0;
    final today = days.last.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = columns.length;
            final cellSize = (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: columns
                  .map(
                    (column) => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: column
                          .map(
                            (day) {
                              final isToday = day != null && day.date == today;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: gap),
                                child: Tooltip(
                                  message: day == null
                                      ? ''
                                      : '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-'
                                          '${day.date.day.toString().padLeft(2, '0')}: '
                                          '${day.count} run${day.count == 1 ? '' : 's'}',
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      color: day == null ? Colors.transparent : _colorFor(day.count),
                                      borderRadius: BorderRadius.circular(4),
                                      border: isToday ? Border.all(color: AppColors.flame, width: 2) : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Less', style: TextStyle(color: AppColors.inkSecondary, fontSize: 11)),
            const SizedBox(width: 6),
            ...[0, 1, 2, 3].map(
              (level) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _colorFor(level), borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
            const Text('More', style: TextStyle(color: AppColors.inkSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
