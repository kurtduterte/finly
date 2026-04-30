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

  Future<Map<String, int>> _downloadCategories() {
    return _merge(
      remoteItems: remote.watchCategories().first,
      localItems: db.categoriesDao.getAll(),
      localRemoteId: (l) => l.remoteId,
      localId: (l) => l.id,
      remoteId: (r) => r.remoteId,
      remoteUpdatedAt: (r) => r.updatedAt,
      localUpdatedAt: (l) => l.updatedAt,
      onUpdate: (loc, rem) => db.categoriesDao.updateCategory(loc.copyWith(
        name: rem.name,
        iconCodepoint: rem.iconCodepoint,
        color: rem.color,
        updatedAt: rem.updatedAt,
      )),
      onInsert: (rem) => db.categoriesDao.insertCategory(CategoriesCompanion(
        name: Value(rem.name),
        iconCodepoint: Value(rem.iconCodepoint),
        color: Value(rem.color),
        isDefault: Value(rem.isDefault),
        remoteId: Value(rem.remoteId),
        createdAt: Value(rem.createdAt),
        updatedAt: Value(rem.updatedAt),
      )),
    );
  }

  Future<Map<String, int>> _downloadAccounts() {
    return _merge(
      remoteItems: remote.watchAccounts().first,
      localItems: db.accountsDao.getAll(),
      localRemoteId: (l) => l.remoteId,
      localId: (l) => l.id,
      remoteId: (r) => r.remoteId,
      remoteUpdatedAt: (r) => r.updatedAt,
      localUpdatedAt: (l) => l.updatedAt,
      onUpdate: (loc, rem) => db.accountsDao.updateAccount(loc.copyWith(
        name: rem.name,
        type: rem.type,
        balanceCentavos: rem.balanceCentavos,
        color: rem.color,
        updatedAt: rem.updatedAt,
      )),
      onInsert: (rem) => db.accountsDao.insertAccount(AccountsCompanion(
        name: Value(rem.name),
        type: Value(rem.type),
        balanceCentavos: Value(rem.balanceCentavos),
        color: Value(rem.color),
        remoteId: Value(rem.remoteId),
        createdAt: Value(rem.createdAt),
        updatedAt: Value(rem.updatedAt),
      )),
    );
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
      if (catId == null || accId == null) continue;

      final local = localByRemoteId[rem.remoteId];
      if (local != null) {
        if (rem.updatedAt.isAfter(local.updatedAt)) {
          await db.expensesDao.updateExpense(local.copyWith(
            amountCentavos: rem.amountCentavos,
            description: rem.description,
            date: rem.date,
            categoryId: catId,
            accountId: accId,
            updatedAt: rem.updatedAt,
          ));
        }
      } else {
        await db.expensesDao.insertExpense(ExpensesCompanion(
          amountCentavos: Value(rem.amountCentavos),
          description: Value(rem.description),
          date: Value(rem.date),
          categoryId: Value(catId),
          accountId: Value(accId),
          remoteId: Value(rem.remoteId),
          updatedAt: Value(rem.updatedAt),
        ));
      }
    }
  }

  Future<Map<String, int>> _merge<R, L>({
    required Future<List<R>> remoteItems,
    required Future<List<L>> localItems,
    required String? Function(L) localRemoteId,
    required int Function(L) localId,
    required String Function(R) remoteId,
    required DateTime Function(R) remoteUpdatedAt,
    required DateTime Function(L) localUpdatedAt,
    required Future<void> Function(L, R) onUpdate,
    required Future<int> Function(R) onInsert,
  }) async {
    final remote = await remoteItems;
    final local = await localItems;
    final idMap = {
      for (final l in local)
        if (localRemoteId(l) != null) localRemoteId(l)!: localId(l),
    };
    final byRemoteId = {
      for (final l in local)
        if (localRemoteId(l) != null) localRemoteId(l)!: l,
    };
    for (final rem in remote) {
      final loc = byRemoteId[remoteId(rem)];
      if (loc != null) {
        idMap[remoteId(rem)] = localId(loc);
        if (remoteUpdatedAt(rem).isAfter(localUpdatedAt(loc))) {
          await onUpdate(loc, rem);
        }
      } else {
        idMap[remoteId(rem)] = await onInsert(rem);
      }
    }
    return idMap;
  }
}
