import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/scan/data/models/receipt_ocr_insights.dart';
import 'package:finly/features/scan/data/services/receipt_category_resolver.dart';

class ReceiptAnalyzerService {
  const ReceiptAnalyzerService(this._gemma);

  final GemmaService _gemma;

  Future<ParsedExpense?> analyze({
    required String ocrText,
    required List<Category> categories,
    required List<Account> accounts,
  }) async {
    final insights = ReceiptOcrInsights.fromText(ocrText);
    final fallbackDescription =
        insights.merchant ??
        _firstMeaningfulLine(ocrText) ??
        'Receipt purchase';
    final prompt = _buildPrompt(
      ocrText: ocrText,
      categories: categories,
      accounts: accounts,
      merchantHint: insights.merchant,
      amountHintCentavos: insights.amountCentavos,
    );
    final response = await _gemma.generateResponse(prompt);
    final aiParsed = response == null || response.isEmpty
        ? null
        : parseExpenseResponse(
            response,
            fallbackDescription: fallbackDescription,
          );
    final extracted =
        aiParsed ??
        _buildHeuristicFallback(
          amountCentavos: insights.amountCentavos,
          description: fallbackDescription,
          accounts: accounts,
        ) ??
        tryRuleBasedExtract(
          ocrText,
          DateTime.now(),
          accounts: accounts,
        );
    if (extracted == null) return null;
    return _normalizeExtracted(
      extracted: extracted,
      insights: insights,
      categories: categories,
      accounts: accounts,
      ocrText: ocrText,
      fallbackDescription: fallbackDescription,
    );
  }

  String _buildPrompt({
    required String ocrText,
    required List<Category> categories,
    required List<Account> accounts,
    required String? merchantHint,
    required int? amountHintCentavos,
  }) {
    final catNames = categories.map((c) => c.name).join(', ');
    final accNames = accounts.map((a) => a.name).join(', ');
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final todayStr = '${now.year}-$mm-$dd';
    final amountHint = amountHintCentavos == null
        ? 'unknown'
        : (amountHintCentavos / 100).toStringAsFixed(2);
    final merchantHintText = merchantHint ?? 'unknown';

    return 'Extract expense details from this receipt OCR text. '
        'Respond ONLY with JSON, no other text.\n'
        'Rules:\n'
        '- Use the final payable amount from lines like GRAND TOTAL, TOTAL, '
        'AMOUNT DUE, or BALANCE DUE.\n'
        '- Ignore subtotal, VAT/tax, discount, cash tendered, and change.\n'
        '- Never use quantity, item count, or line number as the amount.\n'
        '- Description must be the merchant name and must not be empty.\n'
        '- Category must be exactly one value from the provided categories.\n'
        '- Date must be YYYY-MM-DD and should be today when missing.\n'
        'Output format:\n'
        '{"amount":0.00,"description":"","category":"",'
        '"account":"","date":""}\n\n'
        'Categories: $catNames\n'
        'Accounts: $accNames\n'
        'Today: $todayStr. Default category: Other. Default account: Cash.\n'
        'Heuristic hints (use unless OCR clearly contradicts): '
        'merchant="$merchantHintText", total="$amountHint". '
        'Infer category from merchant type.\n\n'
        'Receipt text:\n$ocrText';
  }

  ParsedExpense? _buildHeuristicFallback({
    required int? amountCentavos,
    required String description,
    required List<Account> accounts,
  }) {
    if (amountCentavos == null || amountCentavos <= 0) return null;
    final accountName = _resolveDefaultAccount(accounts);
    return ParsedExpense(
      amountCentavos: amountCentavos,
      description: description,
      categoryName: 'Other',
      accountName: accountName,
      date: DateTime.now(),
    );
  }

  ParsedExpense _normalizeExtracted({
    required ParsedExpense extracted,
    required ReceiptOcrInsights insights,
    required List<Category> categories,
    required List<Account> accounts,
    required String ocrText,
    required String fallbackDescription,
  }) {
    final amountCentavos = _resolveAmountCentavos(
      ocrAmountCentavos: insights.amountCentavos,
      ocrAmountConfidence: insights.amountConfidence,
      parsedAmountCentavos: extracted.amountCentavos,
    );
    final description = extracted.description.trim().isEmpty
        ? fallbackDescription
        : extracted.description.trim();
    final categoryName = ReceiptCategoryResolver.resolve(
      categories: categories,
      proposedCategory: extracted.categoryName,
      merchant: description,
      ocrText: ocrText,
    );
    final accountName = _resolveAccountName(accounts, extracted.accountName);

    return ParsedExpense(
      amountCentavos: amountCentavos,
      description: description,
      categoryName: categoryName,
      accountName: accountName,
      date: extracted.date,
    );
  }

  int _resolveAmountCentavos({
    required int? ocrAmountCentavos,
    required int ocrAmountConfidence,
    required int parsedAmountCentavos,
  }) {
    if (ocrAmountCentavos == null || ocrAmountCentavos <= 0) {
      return parsedAmountCentavos;
    }
    if (parsedAmountCentavos <= 0) return ocrAmountCentavos;
    if (parsedAmountCentavos == ocrAmountCentavos) return ocrAmountCentavos;

    final diffCentavos = (parsedAmountCentavos - ocrAmountCentavos).abs();
    if (diffCentavos <= 100) return ocrAmountCentavos;

    final bigger = parsedAmountCentavos > ocrAmountCentavos
        ? parsedAmountCentavos
        : ocrAmountCentavos;
    final smaller = parsedAmountCentavos < ocrAmountCentavos
        ? parsedAmountCentavos
        : ocrAmountCentavos;
    final mismatchRatio = smaller == 0 ? 999.0 : bigger / smaller;

    if (ocrAmountConfidence >= 16) return ocrAmountCentavos;
    if (ocrAmountConfidence <= 10 && mismatchRatio >= 1.2) {
      return parsedAmountCentavos;
    }
    if (ocrAmountConfidence <= 13 && mismatchRatio >= 2.0) {
      return parsedAmountCentavos;
    }
    return ocrAmountCentavos;
  }

  String _resolveDefaultAccount(List<Account> accounts) {
    for (final account in accounts) {
      if (account.name.toLowerCase() == 'cash') return account.name;
    }
    return accounts.isEmpty ? 'Cash' : accounts.first.name;
  }

  String _resolveAccountName(List<Account> accounts, String accountName) {
    final matched = matchAccount(accounts, accountName);
    if (matched != null) return matched.name;
    return _resolveDefaultAccount(accounts);
  }

  String? _firstMeaningfulLine(String ocrText) {
    final lines = ocrText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    for (final line in lines) {
      if (RegExp('[A-Za-z]').hasMatch(line)) return line;
    }
    return lines.first;
  }
}
