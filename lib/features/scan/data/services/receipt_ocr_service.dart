import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptOcrService {
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizer = TextRecognizer();
    try {
      final result = await recognizer.processImage(inputImage);
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}
