import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finly/core/db/daos/accounts_dao.dart';
import 'package:finly/core/db/daos/categories_dao.dart';
import 'package:finly/core/db/daos/conversations_dao.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/core/db/daos/receipts_dao.dart';
import 'package:finly/core/db/tables/accounts_table.dart';
import 'package:finly/core/db/tables/categories_table.dart';
import 'package:finly/core/db/tables/chat_messages_table.dart';
import 'package:finly/core/db/tables/conversations_table.dart';
import 'package:finly/core/db/tables/expenses_table.dart';
import 'package:finly/core/db/tables/receipts_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';
part 'seed_data.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Receipts,
    Expenses,
    Conversations,
    ChatMessages,
  ],
  daos: [
    AccountsDao,
    CategoriesDao,
    ReceiptsDao,
    ExpensesDao,
    ConversationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'finly_db'));

  @override
  int get schemaVersion => 6;

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
    onUpgrade: (m, from, to) async {
      // m.addColumn() generates DEFAULT CURRENT_TIMESTAMP (an expression),
      // but SQLite ALTER TABLE ADD COLUMN only accepts literal defaults on
      // older Android SQLite versions — causing a silent failure via safe().
      // Use raw SQL with literal defaults instead.
      Future<void> safe(String sql) async {
        try {
          await customStatement(sql);
        } on Exception {
          // Ignore "duplicate column name" errors — migration is idempotent.
        }
      }

      if (from < 2) {
        await m.createTable(conversations);
        await m.createTable(chatMessages);
      }
      if (from < 6) {
        // v4→v5 used m.addColumn() which generates DEFAULT CURRENT_TIMESTAMP
        // (an expression). SQLite ALTER TABLE ADD COLUMN rejects non-literal
        // defaults on older Android versions, so those calls failed silently.
        // Re-apply here with raw SQL + literal defaults so it always works.
        // DateTime columns are INTEGER (ms since epoch); 0 = epoch default.
        await safe('ALTER TABLE expenses ADD COLUMN remote_id TEXT');
        await safe('ALTER TABLE expenses'
            ' ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
        await safe('ALTER TABLE accounts ADD COLUMN remote_id TEXT');
        await safe('ALTER TABLE accounts'
            ' ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
        await safe('ALTER TABLE categories ADD COLUMN remote_id TEXT');
        await safe('ALTER TABLE categories'
            ' ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
        await safe('ALTER TABLE categories'
            ' ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
        await safe('ALTER TABLE receipts ADD COLUMN remote_id TEXT');
        await safe('ALTER TABLE receipts'
            ' ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
      }
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
