import 'dart:async';
import 'dart:io';

import 'package:finly/ai/ai_message.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

const _kModelFileName = 'gemma3-1b-it-int4.task';

Future<String> _modelFilePath() async {
  final dir = await getExternalStorageDirectory();
  if (dir == null) {
    throw Exception('External storage not available on this device.');
  }
  return '${dir.path}/$_kModelFileName';
}

class GemmaService {
  InferenceModel? _model;

  Future<bool> isModelReady() async => FlutterGemma.hasActiveModel();

  Future<String> get modelPath => _modelFilePath();

  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {
    final path = await _modelFilePath();
    if (!File(path).existsSync()) {
      throw Exception('Model file not found.\nRun: make push-model');
    }
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromFile(path)
        .withProgress((p) => onProgress?.call(p / 100))
        .install();
  }

  Future<String?> generateResponse(String prompt) async {
    _model ??= await FlutterGemma.getActiveModel();
    final chat = await _model!.createChat();
    await chat.addQueryChunk(Message.text(text: prompt));
    final buffer = StringBuffer();
    await for (final token in chat.generateChatResponseAsync()) {
      if (token is TextResponse) buffer.write(token.token);
    }
    return buffer.toString();
  }

  Stream<String> streamResponse(String prompt) async* {
    _model ??= await FlutterGemma.getActiveModel();
    final chat = await _model!.createChat();
    await chat.addQueryChunk(Message.text(text: prompt));
    await for (final token in chat.generateChatResponseAsync()) {
      if (token is TextResponse) yield token.token;
    }
  }

  Stream<String> streamMessages(List<AiMessage> messages) async* {
    _model ??= await FlutterGemma.getActiveModel();
    final chat = await _model!.createChat();
    for (final m in messages) {
      await chat.addQueryChunk(Message.text(text: m.text, isUser: m.isUser));
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
