const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Fri, 28 Nov · 6:30 PM" — used everywhere a run's start time is shown,
/// instead of DateTime's raw toString().
String formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final weekday = _weekdays[local.weekday - 1];
  final month = _months[local.month - 1];
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$weekday, ${local.day} $month · $hour12:$minute $period';
}

/// "12:03" or "1:02:03" — used on every tracked-run screen for elapsed time.
String formatElapsed(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// "5:30" (minutes:seconds per km), or an em dash before there's enough data.
String formatPace({required double distanceKm, required int durationSeconds}) {
  if (distanceKm <= 0.02) return '–:–';
  final paceMinPerKm = (durationSeconds / 60.0) / distanceKm;
  return formatPaceValue(paceMinPerKm);
}

/// Same as [formatPace], but from an already-computed min/km value (e.g. a
/// split or an activity's stored average pace) rather than distance+duration.
String formatPaceValue(double paceMinPerKm) {
  if (paceMinPerKm <= 0) return '–:–';
  final m = paceMinPerKm.floor();
  final s = ((paceMinPerKm - m) * 60).round();
  return '$m:${s.toString().padLeft(2, '0')}';
}
