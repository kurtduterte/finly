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

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
