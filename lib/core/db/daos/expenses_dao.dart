import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/tables/accounts_table.dart';
import 'package:finly/core/db/tables/categories_table.dart';
import 'package:finly/core/db/tables/expenses_table.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses, Categories, Accounts])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.attachedDatabase);

  Stream<List<Expense>> watchAll() => select(expenses).watch();

  Future<List<Expense>> getAll() => select(expenses).get();

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();
}
