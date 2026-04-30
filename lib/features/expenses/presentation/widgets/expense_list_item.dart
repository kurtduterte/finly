import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:finly/core/utils/date_format.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseListItem extends ConsumerWidget {
  const ExpenseListItem({required this.item, super.key});
  final ExpenseWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final expense = item.expense;
    final category = item.category;
    final account = item.account;
    final color = parseHexColor(category.color);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(cs),
      confirmDismiss: (_) async => true,
      onDismissed: (_) async {
        final undo = ExpensesCompanion.insert(
          amountCentavos: expense.amountCentavos,
          description: expense.description,
          date: expense.date,
          categoryId: expense.categoryId,
          accountId: expense.accountId,
        );
        await ref.read(expensesNotifierProvider.notifier).delete(expense.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Expense deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(
              ref.read(expensesNotifierProvider.notifier).add(undo),
            ),
          ),
        ));
      },
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(kRadius16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseFormScreen(initial: item),
            ),
          ),
          borderRadius: BorderRadius.circular(kRadius16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius16),
              border: Border.all(color: cs.outline, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(kRadius16),
                      bottomLeft: Radius.circular(kRadius16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(kRadius10),
                  ),
                  child: Icon(
                    IconData(
                      category.iconCodepoint,
                      fontFamily: 'MaterialIcons',
                    ),
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${account.name} · ${formatShortDate(expense.date)}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    formatPeso(expense.amountCentavos),
                    style: TextStyle(
                      color: cs.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _deleteBackground(ColorScheme cs) => Container(
  alignment: Alignment.centerRight,
  padding: const EdgeInsets.only(right: 20),
  decoration: BoxDecoration(
    color: cs.error.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(kRadius16),
    border: Border.all(color: cs.error.withValues(alpha: 0.4), width: 0.5),
  ),
  child: Icon(Icons.delete_rounded, color: cs.error, size: 22),
);
