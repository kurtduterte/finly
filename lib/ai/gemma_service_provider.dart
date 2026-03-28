import 'package:finly/ai/gemma_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  final service = GemmaService();
  ref.onDispose(service.dispose);
  return service;
});
