import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:finly/features/scan/presentation/screens/scan_screen.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_rounded,
            label: 'Add Expense',
            accent: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ExpenseFormScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.document_scanner_rounded,
            label: 'Scan Receipt',
            accent: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ScanScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = accent ? cs.primaryContainer : cs.surfaceContainerHighest;
    final borderColor = accent ? cs.inversePrimary : cs.outline;
    final fgColor = accent ? cs.primary : cs.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(kRadius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius14),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: fgColor, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
