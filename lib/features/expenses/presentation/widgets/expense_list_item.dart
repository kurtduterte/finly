import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

Color _parseColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class ExpenseListItem extends ConsumerWidget {
  const ExpenseListItem({required this.item, super.key});
  final ExpenseWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = item.expense;
    final category = item.category;
    final account = item.account;
    final amount = expense.amountCentavos / 100;
    final color = _parseColor(category.color);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) async {
        await ref.read(expensesNotifierProvider.notifier).delete(expense.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => unawaited(
                  ref.read(expensesNotifierProvider.notifier).add(
                        ExpensesCompanion.insert(
                          amountCentavos: expense.amountCentavos,
                          description: expense.description,
                          date: expense.date,
                          categoryId: expense.categoryId,
                          accountId: expense.accountId,
                        ),
                      ),
                ),
              ),
            ),
          );
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            IconData(category.iconCodepoint, fontFamily: 'MaterialIcons'),
            color: color,
          ),
        ),
        title: Text(expense.description),
        subtitle:
            Text('${account.name} · ${_shortDate(expense.date)}'),
        trailing: Text(
          '₱${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExpenseFormScreen(initial: item),
          ),
        ),
      ),
    );
  }
}
