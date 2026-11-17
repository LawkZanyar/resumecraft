import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Overridden in `main.dart` (and in tests) with a loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// Shared id generator so tests can inject deterministic ids.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Clock used by features that schedule or compare dates; tests override it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
