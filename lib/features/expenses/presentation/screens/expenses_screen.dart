import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:finly/features/expenses/presentation/widgets/empty_expenses.dart';
import 'package:finly/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:finly/features/expenses/presentation/widgets/expenses_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesListProvider);

    return Scaffold(
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (expenses) {
            final total = expenses.fold<int>(
              0,
              (sum, e) => sum + e.expense.amountCentavos,
            );
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ExpensesHeader(
                    count: expenses.length,
                    totalCentavos: total,
                  ),
                ),
                if (expenses.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyExpenses(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          ExpenseListItem(item: expenses[i]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExpenseFormScreen(),
          ),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
