import 'dart:async';

import 'package:finly/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:finly/features/scan/presentation/providers/scan_providers.dart';
import 'package:finly/features/scan/presentation/widgets/scan_action_buttons.dart';
import 'package:finly/features/scan/presentation/widgets/scan_processing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    ref.listen(scanStateProvider, (_, next) {
      if (next.status == ScanStatus.done) {
        unawaited(
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseFormScreen(
                prefill: next.parsedExpense != null
                    ? ScanPrefill(
                        amountCentavos: next.parsedExpense!.amountCentavos,
                        description: next.parsedExpense!.description,
                        categoryName: next.parsedExpense!.categoryName,
                        accountName: next.parsedExpense!.accountName,
                        date: next.parsedExpense!.date,
                        receiptId: next.receiptId,
                      )
                    : null,
              ),
            ),
          ).then((_) {
            ref.read(scanStateProvider.notifier).reset();
          }),
        );
      }
    });

    final state = ref.watch(scanStateProvider);
    final isProcessing = state.status != ScanStatus.idle &&
        state.status != ScanStatus.done;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Scan Receipt',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Photo → AI → expense entry',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            if (isProcessing)
              Expanded(
                child: Center(
                  child: ScanProcessingView(
                    state: state,
                    onRetry: () =>
                        ref.read(scanStateProvider.notifier).reset(),
                  ),
                ),
              )
            else ...[
              const Spacer(),
              const ScanActionButtons(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
