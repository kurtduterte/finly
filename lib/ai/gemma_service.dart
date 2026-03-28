import 'dart:async';

import 'package:finly/config/ai_config.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  InferenceModel? _model;

  // Returns true if the model is already loaded and ready to use
  Future<bool> isModelReady() async => FlutterGemma.hasActiveModel();

  // Loads the bundled model asset; calls onProgress(0.0→1.0) during loading
  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromAsset(kGemmaAssetPath)
        .withProgress((p) => onProgress?.call(p / 100))
        .install();
  }

  // Sends prompt to Gemma and returns the full response as a string
  Future<String?> generateResponse(String prompt) async {
    _model ??= await FlutterGemma.getActiveModel();

    final chat = await _model!.createChat();
    await chat.addQueryChunk(Message.text(text: prompt));
    final buffer = StringBuffer();
    await for (final token in chat.generateChatResponseAsync()) {
      if (token is TextResponse) {
        buffer.write(token.token);
      }
    }
    return buffer.toString();
  }

  // Streams tokens from Gemma as they are generated
  Stream<String> streamResponse(String prompt) async* {
    _model ??= await FlutterGemma.getActiveModel();
    final chat = await _model!.createChat();
    await chat.addQueryChunk(Message.text(text: prompt));
    await for (final token in chat.generateChatResponseAsync()) {
      if (token is TextResponse) yield token.token;
    }
  }

  void dispose() {
    unawaited(_model?.close());
    _model = null;
  }
}
