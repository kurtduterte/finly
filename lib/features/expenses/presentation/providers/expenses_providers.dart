import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/expenses/data/repositories/expenses_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(db: ref.watch(appDatabaseProvider));
});

final expensesListProvider = StreamProvider<List<ExpenseWithDetails>>((ref) {
  return ref.watch(expensesRepositoryProvider).watchAllWithDetails();
});

final categoriesListProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(expensesRepositoryProvider).getAllCategories();
});

final accountsListProvider = FutureProvider<List<Account>>((ref) {
  return ref.watch(expensesRepositoryProvider).getAllAccounts();
});

class ExpensesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> add(ExpensesCompanion entry) =>
      ref.read(expensesRepositoryProvider).addExpense(entry);

  Future<void> updateExpense(Expense expense) =>
      ref.read(expensesRepositoryProvider).updateExpense(expense);

  Future<void> delete(int id) =>
      ref.read(expensesRepositoryProvider).deleteExpense(id);
}

final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, void>(ExpensesNotifier.new);
