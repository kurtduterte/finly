import 'package:finly/ai/ai_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kUnavailable = 'AI is not available on web.';

class GemmaService {
  Future<bool> isModelReady() async => true;

  Future<String> get modelPath async => '';

  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {}

  Future<String?> generateResponse(String prompt) async => _kUnavailable;

  Stream<String> streamResponse(String prompt) async* {
    yield _kUnavailable;
  }

  Stream<String> streamMessages(List<AiMessage> messages) async* {
    yield _kUnavailable;
  }

  void dispose() {}
}

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  final service = GemmaService();
  ref.onDispose(service.dispose);
  return service;
});
