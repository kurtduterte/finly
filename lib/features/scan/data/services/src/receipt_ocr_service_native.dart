import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptOcrService {
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizer = TextRecognizer();
    try {
      final result = await recognizer.processImage(inputImage);
      final normalizedText = _buildNormalizedText(result);
      return normalizedText.isEmpty ? result.text : normalizedText;
    } finally {
      await recognizer.close();
    }
  }

  String _buildNormalizedText(RecognizedText recognizedText) {
    final lines = <_OcrLine>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isEmpty) continue;
        lines.add(
          _OcrLine(
            text: text,
            top: line.boundingBox.top,
            left: line.boundingBox.left,
            height: line.boundingBox.height,
          ),
        );
      }
    }
    if (lines.isEmpty) return recognizedText.text.trim();

    lines.sort((a, b) {
      if (!_isSameRow(a, b)) return a.top.compareTo(b.top);
      return a.left.compareTo(b.left);
    });

    final orderedLines = <String>[];
    for (final line in lines) {
      if (orderedLines.isNotEmpty && orderedLines.last == line.text) continue;
      orderedLines.add(line.text);
    }
    return orderedLines.join('\n').trim();
  }

  bool _isSameRow(_OcrLine first, _OcrLine second) {
    final tolerance = (first.height + second.height) * 0.25;
    return (first.top - second.top).abs() <= tolerance;
  }
}

class _OcrLine {
  const _OcrLine({
    required this.text,
    required this.top,
    required this.left,
    required this.height,
  });

  final String text;
  final double top;
  final double left;
  final double height;
}
