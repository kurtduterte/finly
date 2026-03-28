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

  Future<void> addExpense(ExpensesCompanion entry) =>
      db.expensesDao.insertExpense(entry);

  Future<void> updateExpense(Expense expense) =>
      db.expensesDao.updateExpense(expense);

  Future<void> deleteExpense(int id) => db.expensesDao.deleteExpense(id);
}
