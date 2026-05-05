import 'dart:async';

import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:finly/features/scan/presentation/providers/qr_scan_providers.dart';
import 'package:finly/features/scan/presentation/widgets/qr_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({this.startWithGallery = false, super.key});

  final bool startWithGallery;

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  late final MobileScannerController _controller;
  bool _torchOn = false;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrScanProvider.notifier).reset();
      if (widget.startWithGallery) unawaited(_pickFromGallery());
    });
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _pickFromGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final capture = await _controller.analyzeImage(file.path);
    if (capture != null) _handleCapture(capture);
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_detected) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _detected = true;
    unawaited(_controller.stop());
    unawaited(ref.read(qrScanProvider.notifier).processQrContent(value));
  }

  void _onError(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'QR analysis failed')),
    );
    setState(() => _detected = false);
    unawaited(_controller.start());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(qrScanProvider, (_, next) {
      if (next.status == QrScanStatus.done) {
        final p = next.parsedExpense;
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseFormScreen(
                prefill: p != null
                    ? ScanPrefill(
                        amountCentavos: p.amountCentavos,
                        description: p.description,
                        categoryName: p.categoryName,
                        accountName: p.accountName,
                        date: p.date,
                      )
                    : null,
              ),
            ),
          ),
        );
      } else if (next.status == QrScanStatus.error) {
        _onError(context, next.errorMessage);
      }
    });

    final isAnalyzing =
        ref.watch(qrScanProvider).status == QrScanStatus.analyzing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleCapture),
          const QrOverlay(),
          if (isAnalyzing)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0x99000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _torchOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleFlash,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _pickFromGallery,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
