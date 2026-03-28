import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finly/core/db/daos/accounts_dao.dart';
import 'package:finly/core/db/daos/categories_dao.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/core/db/daos/receipts_dao.dart';
import 'package:finly/core/db/tables/accounts_table.dart';
import 'package:finly/core/db/tables/categories_table.dart';
import 'package:finly/core/db/tables/expenses_table.dart';
import 'package:finly/core/db/tables/receipts_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';
part 'seed_data.dart';

@DriftDatabase(
  tables: [Accounts, Categories, Receipts, Expenses],
  daos: [AccountsDao, CategoriesDao, ReceiptsDao, ExpensesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'finly_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await batch((b) {
            b
              ..insertAll(categories, SeedData.defaultCategories)
              ..insertAll(accounts, SeedData.defaultAccounts);
          });
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
