/// Helpers for converting entities to and from plain maps (Firestore / JSON).
/// Dates are stored as UTC ISO-8601 strings so they sort correctly.
library;

String str(Object? v, [String fallback = '']) => v is String ? v : fallback;

String? strOrNull(Object? v) => v is String && v.isNotEmpty ? v : null;

int intOf(Object? v, [int fallback = 0]) => switch (v) {
      final int i => i,
      final num n => n.round(),
      final String s => int.tryParse(s) ?? fallback,
      _ => fallback,
    };

int? intOrNull(Object? v) => switch (v) {
      final int i => i,
      final num n => n.round(),
      final String s => int.tryParse(s),
      _ => null,
    };

double? doubleOrNull(Object? v) => switch (v) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s),
      _ => null,
    };

bool boolOf(Object? v, [bool fallback = false]) => v is bool ? v : fallback;

DateTime? dateOrNull(Object? v) => switch (v) {
      final DateTime d => d,
      final String s => DateTime.tryParse(s)?.toLocal(),
      final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      _ => null,
    };

DateTime dateOf(Object? v) => dateOrNull(v) ?? DateTime.fromMillisecondsSinceEpoch(0);

String? dateToStr(DateTime? d) => d?.toUtc().toIso8601String();

List<String> strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const <String>[];

List<Map<String, Object?>> mapList(Object? v) => v is List
    ? v.whereType<Map<Object?, Object?>>().map(asMap).toList()
    : const [];

Map<String, Object?> asMap(Object? v) => v is Map
    ? v.map((key, value) => MapEntry(key.toString(), value))
    : <String, Object?>{};

T enumOf<T extends Enum>(List<T> values, Object? v, T fallback) =>
    values.firstWhere((e) => e.name == v, orElse: () => fallback);
