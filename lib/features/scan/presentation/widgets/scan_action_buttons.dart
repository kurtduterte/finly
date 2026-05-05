import 'dart:async';

import 'package:finly/features/scan/presentation/screens/qr_scan_screen.dart'
    if (dart.library.html) 'package:finly/core/stubs/qr_scan_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ScanActionButtons extends StatelessWidget {
  const ScanActionButtons({super.key});

  void _showQrOptions(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded),
                title: const Text('Scan with Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const QrScanScreen(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Upload from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const QrScanScreen(startWithGallery: true),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: () => _showQrOptions(context),
      icon: const Icon(Icons.qr_code_scanner_rounded),
      label: const Text('Scan QR Code'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
