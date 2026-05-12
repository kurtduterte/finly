import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/sync/data/datasources/firestore_datasource.dart';
import 'package:finly/features/sync/data/models/firestore_account.dart';
import 'package:finly/features/sync/data/models/firestore_category.dart';
import 'package:finly/features/sync/data/models/firestore_expense.dart';
import 'package:uuid/uuid.dart';

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

  Future<String> _ensureCategoryRemoteId(Category category) async {
    if (category.remoteId != null) return category.remoteId!;
    final remoteId = _uuid.v4();
    await db.categoriesDao.updateCategory(
      category.copyWith(remoteId: Value(remoteId)),
    );
    return remoteId;
  }

  Future<String> _ensureAccountRemoteId(Account account) async {
    if (account.remoteId != null) return account.remoteId!;
    final remoteId = _uuid.v4();
    await db.accountsDao.updateAccount(
      account.copyWith(remoteId: Value(remoteId)),
    );
    return remoteId;
  }

  Future<String> _ensureExpenseRemoteId(Expense expense) async {
    if (expense.remoteId != null) return expense.remoteId!;
    final remoteId = _uuid.v4();
    await db.expensesDao.updateExpense(
      expense.copyWith(remoteId: Value(remoteId)),
    );
    return remoteId;
  }

  Future<void> _uploadCategories() async {
    final categories = await db.categoriesDao.getAll();
    for (final category in categories) {
      final remoteId = await _ensureCategoryRemoteId(category);
      await remote.upsertCategory(
        FirestoreCategory(
          remoteId: remoteId,
          name: category.name,
          iconCodepoint: category.iconCodepoint,
          color: category.color,
          isDefault: category.isDefault,
          createdAt: category.createdAt,
          updatedAt: category.updatedAt,
        ),
      );
    }
  }

  Future<void> _uploadAccounts() async {
    final accounts = await db.accountsDao.getAll();
    for (final account in accounts) {
      final remoteId = await _ensureAccountRemoteId(account);
      await remote.upsertAccount(
        FirestoreAccount(
          remoteId: remoteId,
          name: account.name,
          type: account.type,
          balanceCentavos: account.balanceCentavos,
          color: account.color,
          createdAt: account.createdAt,
          updatedAt: account.updatedAt,
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

    for (final expense in expenses) {
      final catRemoteId = catRemoteById[expense.categoryId];
      final accRemoteId = accRemoteById[expense.accountId];
      if (catRemoteId == null || accRemoteId == null) continue;

      final remoteId = await _ensureExpenseRemoteId(expense);
      await remote.upsertExpense(
        FirestoreExpense(
          remoteId: remoteId,
          amountCentavos: expense.amountCentavos,
          description: expense.description,
          date: expense.date,
          categoryRemoteId: catRemoteId,
          accountRemoteId: accRemoteId,
          updatedAt: expense.updatedAt,
        ),
      );
    }
  }
}
