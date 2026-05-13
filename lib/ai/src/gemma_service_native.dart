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
  static Future<void> _requestQueue = Future<void>.value();

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

  Stream<String> streamMessages(List<AiMessage> messages) {
    var isCancelled = false;
    InferenceModelSession? activeSession;
    Future<void>? stopFuture;

    Future<void> requestStop(InferenceModelSession session) {
      final existing = stopFuture;
      if (existing != null) return existing;
      final future = session.stopGeneration();
      stopFuture = future;
      return future;
    }

    final controller = StreamController<String>(
      onCancel: () async {
        isCancelled = true;
        final session = activeSession;
        if (session != null) {
          await requestStop(session);
        }
      },
    );

    unawaited(
      _enqueue<void>(() async {
        final model = await _activeModel();
        final session = await model.createSession();
        activeSession = session;
        try {
          for (final message in messages) {
            if (isCancelled) return;
            await session.addQueryChunk(
              Message.text(text: message.text, isUser: message.isUser),
            );
          }
          if (isCancelled) return;
          await for (final token in session.getResponseAsync()) {
            if (isCancelled) {
              await requestStop(session);
              continue;
            }
            if (!controller.isClosed) {
              controller.add(token);
            }
          }
        } finally {
          activeSession = null;
          if (stopFuture != null) {
            try {
              await stopFuture;
            } finally {
              await session.close();
            }
          } else {
            await session.close();
          }
        }
      }).then(
        (_) async {
          if (!controller.isClosed) {
            await controller.close();
          }
        },
        onError: (Object error, StackTrace stackTrace) async {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
            await controller.close();
          }
        },
      ),
    );

    return controller.stream;
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _requestQueue = _requestQueue.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
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
