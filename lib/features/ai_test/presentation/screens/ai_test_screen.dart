import 'package:finly/ai/gemma_service.dart';
import 'package:flutter/material.dart';

class AiTestScreen extends StatefulWidget {
  const AiTestScreen({required this.gemmaService, super.key});

  final GemmaService gemmaService;

  @override
  State<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  final _controller = TextEditingController();

  bool _isLoading = false;
  String? _response;

  @override
  void dispose() {
    _controller.dispose();
    widget.gemmaService.dispose();
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
      final result = await widget.gemmaService.generateResponse(prompt);
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
      appBar: AppBar(title: const Text('AI Test')),
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
