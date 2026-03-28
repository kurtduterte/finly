import 'dart:async';

import 'package:finly/ai/gemma_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class GemmaSetupState {
  const GemmaSetupState();
}

@immutable
class GemmaSetupIdle extends GemmaSetupState {
  const GemmaSetupIdle();
}

@immutable
class GemmaSetupLoading extends GemmaSetupState {
  const GemmaSetupLoading({required this.progress});

  final double progress;
}

@immutable
class GemmaSetupReady extends GemmaSetupState {
  const GemmaSetupReady();
}

@immutable
class GemmaSetupError extends GemmaSetupState {
  const GemmaSetupError({required this.message});

  final String message;
}

class GemmaSetupNotifier extends Notifier<GemmaSetupState> {
  @override
  GemmaSetupState build() {
    unawaited(_initialize());
    return const GemmaSetupIdle();
  }

  Future<void> _initialize() async {
    final svc = ref.read(gemmaServiceProvider);
    if (await svc.isModelReady()) {
      state = const GemmaSetupReady();
      return;
    }
    try {
      await svc.prepareModel(
        onProgress: (p) => state = GemmaSetupLoading(progress: p),
      );
      state = const GemmaSetupReady();
    } on Exception catch (e) {
      state = GemmaSetupError(message: e.toString());
    }
  }
}

final gemmaSetupProvider =
    NotifierProvider<GemmaSetupNotifier, GemmaSetupState>(
  GemmaSetupNotifier.new,
);
