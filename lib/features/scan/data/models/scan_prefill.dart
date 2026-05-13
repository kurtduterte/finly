import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';
import 'package:finly/features/scan/data/models/receipt_ocr_insights.dart';

class ScanPrefill {
  const ScanPrefill({
    this.amountCentavos,
    this.description,
    this.categoryName,
    this.accountName,
    this.date,
    this.receiptId,
  });

  final int? amountCentavos;
  final String? description;
  final String? categoryName;
  final String? accountName;
  final DateTime? date;
  final int? receiptId;
  static final _descriptionCategorySuffixPattern = RegExp(
    r'\s*-\s*(.+)$',
    caseSensitive: false,
  );

  static ScanPrefill? fromParsed(ParsedExpense? parsed, {int? receiptId}) {
    if (parsed == null) return null;
    return ScanPrefill(
      amountCentavos: parsed.amountCentavos,
      description: _formatDescription(
        merchantOrDescription: parsed.description,
        categoryName: parsed.categoryName,
      ),
      categoryName: parsed.categoryName,
      accountName: parsed.accountName,
      date: parsed.date,
      receiptId: receiptId,
    );
  }

  static ScanPrefill? fromScanResult({
    required ParsedExpense? parsed,
    required String? ocrText,
    int? receiptId,
  }) {
    final insights = ReceiptOcrInsights.fromText(ocrText);

    final hasAnyData =
        parsed != null ||
        insights.merchant != null ||
        insights.amountCentavos != null ||
        receiptId != null;
    if (!hasAnyData) return null;
    final categoryName = parsed?.categoryName;
    final rawDescription = parsed?.description ?? insights.merchant;

    return ScanPrefill(
      amountCentavos: parsed?.amountCentavos ?? insights.amountCentavos,
      description: _formatDescription(
        merchantOrDescription: rawDescription,
        categoryName: categoryName,
      ),
      categoryName: categoryName,
      accountName: parsed?.accountName,
      date: parsed?.date,
      receiptId: receiptId,
    );
  }

  static String? _formatDescription({
    required String? merchantOrDescription,
    required String? categoryName,
  }) {
    final base = merchantOrDescription?.trim();
    if (base == null || base.isEmpty) return null;

    final category = categoryName?.trim();
    if (category == null || category.isEmpty) return base;

    final suffixMatch = _descriptionCategorySuffixPattern.firstMatch(base);
    if (suffixMatch != null) {
      final existingCategory = suffixMatch.group(1)?.trim().toLowerCase();
      if (existingCategory == category.toLowerCase()) return base;
    }

    return '$base - $category';
  }
}
