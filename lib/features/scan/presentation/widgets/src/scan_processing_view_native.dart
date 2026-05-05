import 'dart:io';

import 'package:finly/features/scan/presentation/providers/scan_providers.dart';
import 'package:flutter/material.dart';

class ScanProcessingView extends StatelessWidget {
  const ScanProcessingView({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final ScanState state;
  final VoidCallback onRetry;

  String get _statusLabel => switch (state.status) {
        ScanStatus.pickingImage => 'Opening camera...',
        ScanStatus.extractingText => 'Extracting text from receipt...',
        ScanStatus.analyzingReceipt => 'Analyzing receipt with AI...',
        ScanStatus.error => state.errorMessage ?? 'Something went wrong',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isError = state.status == ScanStatus.error;
    return Column(
      children: [
        if (state.imagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(state.imagePath!),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (!isError) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
        ],
        Text(
          _statusLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError ? cs.error : cs.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
        if (isError) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ],
    );
  }
}
