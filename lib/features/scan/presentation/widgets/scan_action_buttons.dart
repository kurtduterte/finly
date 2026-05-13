import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ScanActionButtons extends StatelessWidget {
  const ScanActionButtons({
    required this.onTakePhoto,
    required this.onUploadReceipt,
    super.key,
  });

  final VoidCallback onTakePhoto;
  final VoidCallback onUploadReceipt;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final cs = Theme.of(context).colorScheme;
      return Text(
        'Receipt scanning is available on Android and iOS.',
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.onSurfaceVariant),
      );
    }

    return Column(
      children: [
        FilledButton.icon(
          onPressed: onTakePhoto,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Take Receipt Photo'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onUploadReceipt,
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('Upload Receipt'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ],
    );
  }
}
