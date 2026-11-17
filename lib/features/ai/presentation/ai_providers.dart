import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_ai_service.dart';
import '../domain/ai_service.dart';

/// The central AI service. Phase 1 uses the offline sample engine.
final aiServiceProvider = Provider<AiService>((ref) => FakeAiService());
