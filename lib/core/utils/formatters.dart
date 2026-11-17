import 'package:intl/intl.dart';

/// Shared display formatting helpers.
abstract final class Formatters {
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, HH:mm');
  static final DateFormat _short = DateFormat('d MMM');

  static String date(DateTime? value) => value == null ? '—' : _date.format(value);
  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value);
  static String shortDate(DateTime? value) =>
      value == null ? '—' : _short.format(value);

  /// "3 days ago", "in 2 hours", "just now".
  static String relative(DateTime value, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = value.difference(ref);
    final future = !diff.isNegative;
    final d = diff.abs();
    String unit;
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) {
      unit = '${d.inMinutes} min';
    } else if (d.inDays < 1) {
      unit = '${d.inHours} h';
    } else if (d.inDays < 30) {
      unit = '${d.inDays} ${d.inDays == 1 ? 'day' : 'days'}';
    } else {
      return date(value);
    }
    return future ? 'in $unit' : '$unit ago';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters;
  }

  static String distanceKm(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
}
