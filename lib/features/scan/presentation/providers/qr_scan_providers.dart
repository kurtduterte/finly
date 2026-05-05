import 'package:finly/ai/gemma_service.dart';
import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/scan/data/services/qr_analyzer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QrScanStatus { idle, analyzing, done, error }

class QrScanState {
  const QrScanState({
    required this.status,
    this.qrContent,
    this.parsedExpense,
    this.errorMessage,
  });

  const QrScanState.idle() : this(status: QrScanStatus.idle);

  final QrScanStatus status;
  final String? qrContent;
  final ParsedExpense? parsedExpense;
  final String? errorMessage;
}

class QrScanNotifier extends Notifier<QrScanState> {
  @override
  QrScanState build() => const QrScanState.idle();

  Future<void> processQrContent(String rawContent) async {
    state = QrScanState(
      status: QrScanStatus.analyzing,
      qrContent: rawContent,
    );
    try {
      final categories = await ref.read(categoriesListProvider.future);
      final accounts = await ref.read(accountsListProvider.future);
      final gemma = ref.read(gemmaServiceProvider);

      final parsed = await QrAnalyzerService(gemma).analyze(
        qrContent: rawContent,
        categories: categories,
        accounts: accounts,
      );

      state = QrScanState(
        status: QrScanStatus.done,
        qrContent: rawContent,
        parsedExpense: parsed,
      );
    } on Exception catch (e) {
      state = QrScanState(
        status: QrScanStatus.error,
        qrContent: rawContent,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const QrScanState.idle();
}

final qrScanProvider = NotifierProvider<QrScanNotifier, QrScanState>(
  QrScanNotifier.new,
);
