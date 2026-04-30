import 'package:finly/features/model_setup/presentation/providers/gemma_setup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GemmaStatusIcon extends ConsumerWidget {
  const GemmaStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(gemmaSetupProvider);
    return switch (state) {
      GemmaSetupReady() => Tooltip(
          message: 'AI ready',
          child: Icon(Icons.psychology_rounded, color: cs.primary),
        ),
      GemmaSetupError(:final message) => Tooltip(
          message: message,
          child: Icon(Icons.error_outline_rounded, color: cs.error),
        ),
      GemmaSetupIdle() => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      GemmaSetupLoading(:final progress) => Tooltip(
          message: 'Setting up AI…',
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: progress, strokeWidth: 2),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
