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
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromFile(path).withProgress((p) => onProgress?.call(p / 100)).install();
  }

  Future<InferenceModel> _activeModel() async {
    _model ??= await FlutterGemma.getActiveModel();
    return _model!;
  }

  Future<String> _collectTokens(Stream<String> tokens) async {
    final chunks = await tokens.toList();
    return chunks.join();
  }

  Future<String?> generateResponse(String prompt) async {
    final tokens = streamResponse(prompt);
    final response = await _collectTokens(tokens);
    if (response.isEmpty) return null;
    return response;
  }

  Stream<String> streamResponse(String prompt) {
    return streamMessages([AiMessage(text: prompt)]);
  }

  Stream<String> streamMessages(List<AiMessage> messages) async* {
    final model = await _activeModel();
    final chat = await model.createChat();
    await Future.forEach<AiMessage>(
      messages,
      (message) => chat.addQueryChunk(
        Message.text(text: message.text, isUser: message.isUser),
      ),
    );
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
