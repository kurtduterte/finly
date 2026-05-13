import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/scan/data/repositories/scan_repository.dart';
import 'package:finly/features/scan/data/services/receipt_analyzer_service.dart';
import 'package:finly/features/scan/data/services/receipt_ocr_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

export 'package:finly/features/scan/data/models/scan_prefill.dart';

enum ScanStatus {
  idle,
  pickingImage,
  extractingText,
  analyzingReceipt,
  done,
  error,
}

class ScanState {
  const ScanState({
    required this.status,
    this.imagePath,
    this.ocrText,
    this.parsedExpense,
    this.receiptId,
    this.errorMessage,
  });

  const ScanState.idle() : this(status: ScanStatus.idle);

  final ScanStatus status;
  final String? imagePath;
  final String? ocrText;
  final ParsedExpense? parsedExpense;
  final int? receiptId;
  final String? errorMessage;
}

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState.idle();

  Future<void> processReceipt(ImageSource source) async {
    state = const ScanState(status: ScanStatus.pickingImage);
    try {
      final imagePath = await _pickImagePath(source);
      if (imagePath == null) {
        state = const ScanState.idle();
        return;
      }

      final ocrText = await _extractReceiptText(imagePath);
      final parsed = await _analyzeReceipt(
        imagePath: imagePath,
        ocrText: ocrText,
      );
      final receiptId = await _saveReceipt(
        imagePath: imagePath,
        ocrText: ocrText,
        parsedExpense: parsed,
      );

      state = ScanState(
        status: ScanStatus.done,
        imagePath: imagePath,
        ocrText: ocrText,
        parsedExpense: parsed,
        receiptId: receiptId,
      );
    } on Exception catch (e) {
      state = ScanState(
        status: ScanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> _pickImagePath(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
    );
    return picked?.path;
  }

  Future<String> _extractReceiptText(String imagePath) async {
    state = ScanState(status: ScanStatus.extractingText, imagePath: imagePath);
    return ReceiptOcrService().extractText(imagePath);
  }

  Future<ParsedExpense?> _analyzeReceipt({
    required String imagePath,
    required String ocrText,
  }) async {
    state = ScanState(
      status: ScanStatus.analyzingReceipt,
      imagePath: imagePath,
      ocrText: ocrText,
    );
    final categories = await ref.read(categoriesListProvider.future);
    final accounts = await ref.read(accountsListProvider.future);
    final gemma = ref.read(gemmaServiceProvider);
    return ReceiptAnalyzerService(gemma).analyze(
      ocrText: ocrText,
      categories: categories,
      accounts: accounts,
    );
  }

  Future<int> _saveReceipt({
    required String imagePath,
    required String ocrText,
    required ParsedExpense? parsedExpense,
  }) {
    return ref
        .read(scanRepositoryProvider)
        .saveReceipt(
          imagePath: imagePath,
          ocrText: ocrText,
          extractedAmountCentavos: parsedExpense?.amountCentavos,
          extractedMerchant: parsedExpense?.description,
        );
  }

  void reset() => state = const ScanState.idle();
}

final scanStateProvider = NotifierProvider<ScanNotifier, ScanState>(
  ScanNotifier.new,
);

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(db: ref.watch(appDatabaseProvider));
});
