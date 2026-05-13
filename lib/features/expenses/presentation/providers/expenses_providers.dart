import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/expenses/data/repositories/expenses_repository.dart';
import 'package:finly/features/settings/presentation/providers/settings_providers.dart';
import 'package:finly/features/sync/presentation/providers/sync_providers.dart';
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

  Future<void> add(ExpensesCompanion entry) async {
    await ref.read(expensesRepositoryProvider).addExpense(entry);
    await _syncIfEnabled();
  }

  Future<void> updateExpense(Expense expense) async {
    await ref.read(expensesRepositoryProvider).updateExpense(expense);
    await _syncIfEnabled();
  }

  Future<void> delete(int id) async {
    await ref.read(expensesRepositoryProvider).deleteExpense(id);
    await _syncIfEnabled();
  }

  Future<void> _syncIfEnabled() async {
    final syncEnabledAsync = ref.read(syncEnabledProvider);
    final syncEnabled = syncEnabledAsync.asData?.value ?? false;
    if (!syncEnabled) return;
    await ref.read(syncNotifierProvider.notifier).syncNow();
  }
}

final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, void>(ExpensesNotifier.new);
