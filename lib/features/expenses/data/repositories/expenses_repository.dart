import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';

class ExpensesRepository {
  const ExpensesRepository({required this.db});
  final AppDatabase db;

  Stream<List<ExpenseWithDetails>> watchAllWithDetails() =>
      db.expensesDao.watchAllWithDetails();

  Future<List<ExpenseWithDetails>> getRecentWithDetails({int limit = 20}) =>
      db.expensesDao.getRecentWithDetails(limit: limit);

  Future<List<Category>> getAllCategories() => db.categoriesDao.getAll();

  Future<List<Account>> getAllAccounts() => db.accountsDao.getAll();

  Future<void> addExpense(ExpensesCompanion entry) => db.transaction(() async {
        await db.expensesDao.insertExpense(entry);
        final account =
            await db.accountsDao.getById(entry.accountId.value);
        await db.accountsDao.updateAccount(
          account.copyWith(
            balanceCentavos:
                account.balanceCentavos - entry.amountCentavos.value,
          ),
        );
      });

  Future<void> updateExpense(Expense newExpense) =>
      db.transaction(() async {
        final old =
            await db.expensesDao.getExpenseById(newExpense.id);

        // Restore old account balance.
        final oldAccount =
            await db.accountsDao.getById(old.accountId);
        await db.accountsDao.updateAccount(
          oldAccount.copyWith(
            balanceCentavos:
                oldAccount.balanceCentavos + old.amountCentavos,
          ),
        );

        // Re-fetch in case old and new account are the same.
        final newAccount =
            await db.accountsDao.getById(newExpense.accountId);
        await db.accountsDao.updateAccount(
          newAccount.copyWith(
            balanceCentavos:
                newAccount.balanceCentavos - newExpense.amountCentavos,
          ),
        );

        await db.expensesDao.updateExpense(newExpense);
      });

  Future<void> deleteExpense(int id) => db.transaction(() async {
        final expense = await db.expensesDao.getExpenseById(id);
        await db.expensesDao.deleteExpense(id);
        final account =
            await db.accountsDao.getById(expense.accountId);
        await db.accountsDao.updateAccount(
          account.copyWith(
            balanceCentavos:
                account.balanceCentavos + expense.amountCentavos,
          ),
        );
      });
}
