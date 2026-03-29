import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';
import 'package:finly/features/sync/data/models/firestore_account.dart';
import 'package:finly/features/sync/data/models/firestore_category.dart';
import 'package:finly/features/sync/data/models/firestore_expense.dart';
import 'package:uuid/uuid.dart';

/// Pushes local SQLite records to Firestore.
///
/// Order: categories → accounts → expenses (expenses depend on the first two
/// having a remoteId so cross-references can be stored).
class SyncUploadRepository {
  const SyncUploadRepository({required this.db, required this.remote});

  final AppDatabase db;
  final FirestoreDataSource remote;

  static const _uuid = Uuid();

  Future<void> uploadAll() async {
    await _uploadCategories();
    await _uploadAccounts();
    await _uploadExpenses();
  }

  Future<void> _uploadCategories() async {
    final cats = await db.categoriesDao.getAll();
    for (final cat in cats) {
      final remoteId = cat.remoteId ?? _uuid.v4();
      if (cat.remoteId == null) {
        await db.categoriesDao.updateCategory(
          cat.copyWith(remoteId: Value(remoteId)),
        );
      }
      await remote.upsertCategory(
        FirestoreCategory(
          remoteId: remoteId,
          name: cat.name,
          iconCodepoint: cat.iconCodepoint,
          color: cat.color,
          isDefault: cat.isDefault,
          createdAt: cat.createdAt,
          updatedAt: cat.updatedAt,
        ),
      );
    }
  }

  Future<void> _uploadAccounts() async {
    final accounts = await db.accountsDao.getAll();
    for (final acc in accounts) {
      final remoteId = acc.remoteId ?? _uuid.v4();
      if (acc.remoteId == null) {
        await db.accountsDao.updateAccount(
          acc.copyWith(remoteId: Value(remoteId)),
        );
      }
      await remote.upsertAccount(
        FirestoreAccount(
          remoteId: remoteId,
          name: acc.name,
          type: acc.type,
          balanceCentavos: acc.balanceCentavos,
          color: acc.color,
          createdAt: acc.createdAt,
          updatedAt: acc.updatedAt,
        ),
      );
    }
  }

  Future<void> _uploadExpenses() async {
    final expenses = await db.expensesDao.getAll();
    final cats = await db.categoriesDao.getAll();
    final accounts = await db.accountsDao.getAll();

    final catRemoteById = {for (final c in cats) c.id: c.remoteId};
    final accRemoteById = {for (final a in accounts) a.id: a.remoteId};

    for (final exp in expenses) {
      final catRemoteId = catRemoteById[exp.categoryId];
      final accRemoteId = accRemoteById[exp.accountId];
      // Skip if dependencies haven't been synced yet (shouldn't happen since
      // we upload categories + accounts first, but guard defensively).
      if (catRemoteId == null || accRemoteId == null) continue;

      final remoteId = exp.remoteId ?? _uuid.v4();
      if (exp.remoteId == null) {
        await db.expensesDao.updateExpense(
          exp.copyWith(remoteId: Value(remoteId)),
        );
      }
      await remote.upsertExpense(
        FirestoreExpense(
          remoteId: remoteId,
          amountCentavos: exp.amountCentavos,
          description: exp.description,
          date: exp.date,
          categoryRemoteId: catRemoteId,
          accountRemoteId: accRemoteId,
          updatedAt: exp.updatedAt,
        ),
      );
    }
  }
}
