import 'package:drift/drift.dart' show Value;
import 'package:finly/core/db/app_database.dart';

class ScanRepository {
  const ScanRepository({required this.db});

  final AppDatabase db;

  Future<int> saveReceipt({
    required String imagePath,
    required String ocrText,
    int? extractedAmountCentavos,
    String? extractedMerchant,
  }) {
    return db.receiptsDao.insertReceipt(
      ReceiptsCompanion.insert(
        imagePath: imagePath,
        aiRawResponse: Value(ocrText),
        extractedAmountCentavos: Value(extractedAmountCentavos),
        extractedMerchant: Value(extractedMerchant),
      ),
    );
  }
}
