import 'dart:async';

import 'package:finly/ai/gemma_service_provider.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/model_setup/presentation/providers/gemma_setup_notifier.dart';
import 'package:finly/features/model_setup/presentation/widgets/model_setup_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiTestScreen extends ConsumerStatefulWidget {
  const AiTestScreen({super.key});

  @override
  ConsumerState<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends ConsumerState<AiTestScreen> {
  final _controller = TextEditingController();

  bool _isLoading = false;
  String? _response;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final setupState = ref.read(gemmaSetupProvider);
      if (setupState is! GemmaSetupReady) {
        unawaited(
          showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (_) => const ModelSetupModal(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _askAi() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final result =
          await ref.read(gemmaServiceProvider).generateResponse(prompt);
      setState(() => _response = result);
    } on Exception catch (e) {
      setState(() => _response = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ask something',
                hintText: 'Hello! What can you do?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _askAi,
              child: const Text('Ask AI'),
            ),
            const SizedBox(height: 12),
            const OutlinedButton(
              onPressed: null,
              child: Text('Scan Receipt (coming soon)'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_response != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_response!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
