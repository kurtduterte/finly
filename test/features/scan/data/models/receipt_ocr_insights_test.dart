import 'package:finly/features/scan/data/models/receipt_ocr_insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptOcrInsights amount extraction', () {
    test('prefers grand total over subtotal, cash, and change', () {
      const text = '''
ABC SUPERMARKET
SUBTOTAL        178.00
VAT 12%          21.36
GRAND TOTAL     199.36
CASH            500.00
CHANGE          300.64
''';

      final insights = ReceiptOcrInsights.fromText(text);

      expect(insights.amountCentavos, 19936);
      expect(insights.amountConfidence, greaterThanOrEqualTo(10));
    });

    test('handles OCR O/o digit confusion in total amount', () {
      const text = '''
TOTAL AMOUNT: 23O.5O
CASH: 500.00
''';

      final insights = ReceiptOcrInsights.fromText(text);

      expect(insights.amountCentavos, 23050);
    });

    test('does not select total items count as payable amount', () {
      const text = '''
Item A              55.00
Item B              45.00
Total Items:            2
TOTAL               100.00
''';

      final insights = ReceiptOcrInsights.fromText(text);

      expect(insights.amountCentavos, 10000);
    });

    test('uses amount line right after total label', () {
      const text = '''
TOTAL
123.45
CASH 200.00
''';

      final insights = ReceiptOcrInsights.fromText(text);

      expect(insights.amountCentavos, 12345);
    });

    test('returns null when no plausible payable amount exists', () {
      const text = '''
OR#: 000123456
DATE: 2026/05/13
TIME: 13:45:00
TERMINAL: 9988776655
''';

      final insights = ReceiptOcrInsights.fromText(text);

      expect(insights.amountCentavos, isNull);
      expect(insights.amountConfidence, 0);
    });
  });
}
