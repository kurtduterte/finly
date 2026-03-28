import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/tables/receipts_table.dart';

part 'receipts_dao.g.dart';

@DriftAccessor(tables: [Receipts])
class ReceiptsDao extends DatabaseAccessor<AppDatabase>
    with _$ReceiptsDaoMixin {
  ReceiptsDao(super.attachedDatabase);

  Stream<List<Receipt>> watchAll() => select(receipts).watch();

  Future<List<Receipt>> getAll() => select(receipts).get();

  Future<int> insertReceipt(ReceiptsCompanion entry) =>
      into(receipts).insert(entry);

  Future<bool> updateReceipt(Receipt receipt) =>
      update(receipts).replace(receipt);

  Future<int> deleteReceipt(int id) =>
      (delete(receipts)..where((t) => t.id.equals(id))).go();
}
