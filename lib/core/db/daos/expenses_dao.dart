import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/tables/accounts_table.dart';
import 'package:finly/core/db/tables/categories_table.dart';
import 'package:finly/core/db/tables/expenses_table.dart';

part 'expenses_dao.g.dart';

class ExpenseWithDetails {
  const ExpenseWithDetails({
    required this.expense,
    required this.category,
    required this.account,
  });
  final Expense expense;
  final Category category;
  final Account account;
}

@DriftAccessor(tables: [Expenses, Categories, Accounts])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.attachedDatabase);

  Stream<List<Expense>> watchAll() => select(expenses).watch();

  Future<List<Expense>> getAll() => select(expenses).get();

  Future<Expense> getExpenseById(int id) =>
      (select(expenses)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Stream<List<ExpenseWithDetails>> watchAllWithDetails() {
    final q = select(expenses)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return q.join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
      innerJoin(accounts, accounts.id.equalsExp(expenses.accountId)),
    ]).watch().map(
          (rows) => rows
              .map(
                (r) => ExpenseWithDetails(
                  expense: r.readTable(expenses),
                  category: r.readTable(categories),
                  account: r.readTable(accounts),
                ),
              )
              .toList(),
        );
  }

  Future<List<ExpenseWithDetails>> getRecentWithDetails({int limit = 20}) {
    final q = select(expenses)
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit);
    return q
        .join([
          innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
          innerJoin(accounts, accounts.id.equalsExp(expenses.accountId)),
        ])
        .get()
        .then(
          (rows) => rows
              .map(
                (r) => ExpenseWithDetails(
                  expense: r.readTable(expenses),
                  category: r.readTable(categories),
                  account: r.readTable(accounts),
                ),
              )
              .toList(),
        );
  }
}
