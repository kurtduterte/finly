import 'package:finly/features/model_setup/presentation/providers/gemma_setup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModelSetupModal extends ConsumerWidget {
  const ModelSetupModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<GemmaSetupState>(gemmaSetupProvider, (_, next) {
      if (next is GemmaSetupReady) Navigator.of(context).pop();
    });

    final setupState = ref.watch(gemmaSetupProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Setting up AI model',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('This only happens once. Please wait…'),
          const SizedBox(height: 24),
          switch (setupState) {
            GemmaSetupIdle() => const LinearProgressIndicator(),
            GemmaSetupLoading(:final progress) => Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            GemmaSetupReady() => const SizedBox.shrink(),
            GemmaSetupError(:final message) => Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          },
        ],
      ),
    );
  }
}
