import 'package:finly/features/scan/presentation/providers/scan_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ScanActionButtons extends ConsumerWidget {
  const ScanActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(scanStateProvider.notifier);
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => notifier.processReceipt(ImageSource.camera),
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Take Photo'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => notifier.processReceipt(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('Upload from Gallery'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ],
    );
  }
}
