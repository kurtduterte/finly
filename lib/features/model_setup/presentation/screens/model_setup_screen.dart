import 'dart:async';

import 'package:finly/ai/gemma_service.dart';
import 'package:finly/features/ai_test/presentation/screens/ai_test_screen.dart';
import 'package:flutter/material.dart';

class ModelSetupScreen extends StatefulWidget {
  const ModelSetupScreen({required this.gemmaService, super.key});

  final GemmaService gemmaService;

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadModel());
  }

  Future<void> _loadModel() async {
    try {
      await widget.gemmaService.prepareModel(
        onProgress: (p) => setState(() => _progress = p),
      );
      if (mounted) {
        unawaited(
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AiTestScreen(gemmaService: widget.gemmaService),
            ),
          ),
        );
      }
    } on Exception catch (_) {
      setState(
        () => _error =
            'Model file missing. Run the developer setup script first.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Setting up Finly AI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This only happens once on first launch',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else ...[
              LinearProgressIndicator(value: _progress > 0 ? _progress : null),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
