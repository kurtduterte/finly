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
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
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
  AppDatabase({required String name})
    : super(
        driftDatabase(
          name: name,
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 6;

  Future<void> _safeStatement(String sql) async {
    try {
      await customStatement(sql);
    } on Exception {
      return;
    }
  }

  Future<void> _applyRemoteColumnsMigration() async {
    const statements = [
      'ALTER TABLE expenses ADD COLUMN remote_id TEXT',
      'ALTER TABLE expenses ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE accounts ADD COLUMN remote_id TEXT',
      'ALTER TABLE accounts ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE categories ADD COLUMN remote_id TEXT',
      'ALTER TABLE categories ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE categories ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE receipts ADD COLUMN remote_id TEXT',
      'ALTER TABLE receipts ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
    ];
    for (final statement in statements) {
      await _safeStatement(statement);
    }
  }

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
      if (from < 2) {
        await m.createTable(conversations);
        await m.createTable(chatMessages);
      }
      if (from < 6) {
        await _applyRemoteColumnsMigration();
      }
    },
  );
}

String _databaseNameForUser(String? uid) {
  if (uid == null || uid.isEmpty) return 'finly_db_guest';
  final safeUid = uid.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
  return 'finly_db_user_$safeUid';
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  final db = AppDatabase(name: _databaseNameForUser(uid));
  ref.onDispose(db.close);
  return db;
});
