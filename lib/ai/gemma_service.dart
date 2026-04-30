import 'dart:async';
import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

const _kModelFileName = 'gemma3-1b-it-int4.task';

Future<String> _modelFilePath() async {
  final dir = await getExternalStorageDirectory();
  return '${dir!.path}/$_kModelFileName';
}

class GemmaService {
  InferenceModel? _model;

  // Returns true if the model is already loaded and ready to use
  Future<bool> isModelReady() async => FlutterGemma.hasActiveModel();

  // Returns the expected on-device model file path
  Future<String> get modelPath => _modelFilePath();

  // Loads the model from device storage; calls onProgress(0.0→1.0)
  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {
    final path = await _modelFilePath();
    if (!File(path).existsSync()) {
      throw Exception(
        'Model file not found.\n'
        'Run: make push-model',
      );
    }
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromFile(path)
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

  // Streams tokens for a multi-turn conversation.
  Stream<String> streamMessages(List<Message> messages) async* {
    _model ??= await FlutterGemma.getActiveModel();
    final chat = await _model!.createChat();
    for (final m in messages) {
      await chat.addQueryChunk(m);
    }
    await for (final token in chat.generateChatResponseAsync()) {
      if (token is TextResponse) yield token.token;
    }
  }

  void dispose() {
    unawaited(_model?.close());
    _model = null;
  }
}

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  final service = GemmaService();
  ref.onDispose(service.dispose);
  return service;
});
