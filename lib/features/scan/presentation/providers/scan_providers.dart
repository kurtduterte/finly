import 'package:drift/drift.dart' show Value;
import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
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

  ScanState copyWith({
    ScanStatus? status,
    String? imagePath,
    String? ocrText,
    ParsedExpense? parsedExpense,
    int? receiptId,
    String? errorMessage,
  }) => ScanState(
    status: status ?? this.status,
    imagePath: imagePath ?? this.imagePath,
    ocrText: ocrText ?? this.ocrText,
    parsedExpense: parsedExpense ?? this.parsedExpense,
    receiptId: receiptId ?? this.receiptId,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState.idle();

  Future<void> processReceipt(ImageSource source) async {
    state = const ScanState(status: ScanStatus.pickingImage);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 90);
      if (file == null) {
        state = const ScanState.idle();
        return;
      }
      final imagePath = file.path;

      state = ScanState(
        status: ScanStatus.extractingText,
        imagePath: imagePath,
      );
      final ocrText = await ReceiptOcrService().extractText(imagePath);

      state = ScanState(
        status: ScanStatus.analyzingReceipt,
        imagePath: imagePath,
        ocrText: ocrText,
      );

      final db = ref.read(appDatabaseProvider);
      final categories = await ref.read(categoriesListProvider.future);
      final accounts = await ref.read(accountsListProvider.future);
      final gemma = ref.read(gemmaServiceProvider);

      final parsed = await ReceiptAnalyzerService(gemma).analyze(
        ocrText: ocrText,
        categories: categories,
        accounts: accounts,
      );

      final receiptId = await db.receiptsDao.insertReceipt(
        ReceiptsCompanion.insert(
          imagePath: imagePath,
          aiRawResponse: Value(ocrText),
          extractedAmountCentavos: Value(parsed?.amountCentavos),
          extractedMerchant: Value(parsed?.description),
        ),
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

  void reset() => state = const ScanState.idle();
}

final scanStateProvider = NotifierProvider<ScanNotifier, ScanState>(
  ScanNotifier.new,
);
