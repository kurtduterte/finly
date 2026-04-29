import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';

class ReceiptAnalyzerService {
  const ReceiptAnalyzerService(this._gemma);

  final GemmaService _gemma;

  Future<ParsedExpense?> analyze({
    required String ocrText,
    required List<Category> categories,
    required List<Account> accounts,
  }) async {
    final prompt = _buildPrompt(
      ocrText: ocrText,
      categories: categories,
      accounts: accounts,
    );
    final response = await _gemma.generateResponse(prompt);
    if (response == null || response.isEmpty) return null;
    return parseExpenseResponse(response);
  }

  String _buildPrompt({
    required String ocrText,
    required List<Category> categories,
    required List<Account> accounts,
  }) {
    final catNames = categories.map((c) => c.name).join(', ');
    final accNames = accounts.map((a) => a.name).join(', ');
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final todayStr = '${now.year}-$mm-$dd';

    return 'Extract expense details from this receipt OCR text. '
        'Respond ONLY with JSON, no other text:\n'
        '{"amount":0.00,"description":"","category":"",'
        '"account":"","date":""}\n\n'
        'Categories: $catNames\n'
        'Accounts: $accNames\n'
        'Today: $todayStr. Default category: Other. Default account: Cash.\n'
        'Use the merchant name as description. '
        'Use the total amount. '
        'Infer category from merchant type.\n\n'
        'Receipt text:\n$ocrText';
  }
}
