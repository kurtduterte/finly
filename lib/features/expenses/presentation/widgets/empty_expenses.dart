import 'package:flutter/material.dart';

class EmptyExpenses extends StatelessWidget {
  const EmptyExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_rounded, size: 56, color: cs.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'No expenses yet',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap + to add your first expense',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }
}
