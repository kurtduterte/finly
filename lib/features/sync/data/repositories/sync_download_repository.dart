import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';

/// Pulls Firestore records into the local SQLite database.
///
/// Conflict resolution: last-write-wins using `updatedAt`. Remote wins only
/// when its timestamp is strictly newer than the local record.
class SyncDownloadRepository {
  const SyncDownloadRepository({required this.db, required this.remote});

  final AppDatabase db;
  final FirestoreDataSource remote;

  Future<void> downloadAll() async {
    final categoryIdMap = await _downloadCategories();
    final accountIdMap = await _downloadAccounts();
    await _downloadExpenses(categoryIdMap, accountIdMap);
  }

  /// Returns a map of {remoteId → local SQLite id} for every known category.
  Future<Map<String, int>> _downloadCategories() async {
    final remoteList = await remote.watchCategories().first;
    final localList = await db.categoriesDao.getAll();

    // Seed map with existing local records that already have a remoteId.
    final idMap = {
      for (final c in localList) if (c.remoteId != null) c.remoteId!: c.id,
    };
    final localByRemoteId = {
      for (final c in localList) if (c.remoteId != null) c.remoteId!: c,
    };

    for (final rem in remoteList) {
      final local = localByRemoteId[rem.remoteId];
      if (local != null) {
        idMap[rem.remoteId] = local.id;
        if (rem.updatedAt.isAfter(local.updatedAt)) {
          await db.categoriesDao.updateCategory(
            local.copyWith(
              name: rem.name,
              iconCodepoint: rem.iconCodepoint,
              color: rem.color,
              updatedAt: rem.updatedAt,
            ),
          );
        }
      } else {
        final id = await db.categoriesDao.insertCategory(
          CategoriesCompanion(
            name: Value(rem.name),
            iconCodepoint: Value(rem.iconCodepoint),
            color: Value(rem.color),
            isDefault: Value(rem.isDefault),
            remoteId: Value(rem.remoteId),
            createdAt: Value(rem.createdAt),
            updatedAt: Value(rem.updatedAt),
          ),
        );
        idMap[rem.remoteId] = id;
      }
    }
    return idMap;
  }

  /// Returns a map of {remoteId → local SQLite id} for every known account.
  Future<Map<String, int>> _downloadAccounts() async {
    final remoteList = await remote.watchAccounts().first;
    final localList = await db.accountsDao.getAll();

    final idMap = {
      for (final a in localList) if (a.remoteId != null) a.remoteId!: a.id,
    };
    final localByRemoteId = {
      for (final a in localList) if (a.remoteId != null) a.remoteId!: a,
    };

    for (final rem in remoteList) {
      final local = localByRemoteId[rem.remoteId];
      if (local != null) {
        idMap[rem.remoteId] = local.id;
        if (rem.updatedAt.isAfter(local.updatedAt)) {
          await db.accountsDao.updateAccount(
            local.copyWith(
              name: rem.name,
              type: rem.type,
              balanceCentavos: rem.balanceCentavos,
              color: rem.color,
              updatedAt: rem.updatedAt,
            ),
          );
        }
      } else {
        final id = await db.accountsDao.insertAccount(
          AccountsCompanion(
            name: Value(rem.name),
            type: Value(rem.type),
            balanceCentavos: Value(rem.balanceCentavos),
            color: Value(rem.color),
            remoteId: Value(rem.remoteId),
            createdAt: Value(rem.createdAt),
            updatedAt: Value(rem.updatedAt),
          ),
        );
        idMap[rem.remoteId] = id;
      }
    }
    return idMap;
  }

  Future<void> _downloadExpenses(
    Map<String, int> categoryIdMap,
    Map<String, int> accountIdMap,
  ) async {
    final remoteList = await remote.watchExpenses().first;
    final localList = await db.expensesDao.getAll();
    final localByRemoteId = {
      for (final e in localList) if (e.remoteId != null) e.remoteId!: e,
    };

    for (final rem in remoteList) {
      final catId = categoryIdMap[rem.categoryRemoteId];
      final accId = accountIdMap[rem.accountRemoteId];
      // If we don't have the referenced category or account locally, skip.
      if (catId == null || accId == null) continue;

      final local = localByRemoteId[rem.remoteId];
      if (local != null) {
        if (rem.updatedAt.isAfter(local.updatedAt)) {
          await db.expensesDao.updateExpense(
            local.copyWith(
              amountCentavos: rem.amountCentavos,
              description: rem.description,
              date: rem.date,
              categoryId: catId,
              accountId: accId,
              updatedAt: rem.updatedAt,
            ),
          );
        }
      } else {
        await db.expensesDao.insertExpense(
          ExpensesCompanion(
            amountCentavos: Value(rem.amountCentavos),
            description: Value(rem.description),
            date: Value(rem.date),
            categoryId: Value(catId),
            accountId: Value(accId),
            remoteId: Value(rem.remoteId),
            updatedAt: Value(rem.updatedAt),
          ),
        );
      }
    }
  }
}
