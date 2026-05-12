import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';

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

  static ScanPrefill? fromParsed(ParsedExpense? parsed, {int? receiptId}) {
    if (parsed == null) return null;
    return ScanPrefill(
      amountCentavos: parsed.amountCentavos,
      description: parsed.description,
      categoryName: parsed.categoryName,
      accountName: parsed.accountName,
      date: parsed.date,
      receiptId: receiptId,
    );
  }
}
