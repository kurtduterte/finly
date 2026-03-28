import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:finly/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesListProvider);

    return Scaffold(
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Tap + to add your first expense',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => ExpenseListItem(item: expenses[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExpenseFormScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
