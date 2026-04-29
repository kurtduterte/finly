import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/color_utils.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

class ExpenseListItem extends ConsumerWidget {
  const ExpenseListItem({required this.item, super.key});
  final ExpenseWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = item.expense;
    final category = item.category;
    final account = item.account;
    final color = parseHexColor(category.color);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.debit.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.debit.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppColors.debit,
          size: 22,
        ),
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
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseFormScreen(initial: item),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
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
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${account.name} · ${_shortDate(expense.date)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
                    style: const TextStyle(
                      color: AppColors.debit,
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
