import 'dart:async';

import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:finly/features/accounts/presentation/providers/accounts_providers.dart';
import 'package:finly/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountsSummaryCard extends ConsumerWidget {
  const AccountsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final total = ref.watch(totalBalanceProvider);

    return GestureDetector(
      onTap: () => unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AccountsScreen()),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(kRadius20),
          border: Border.all(color: cs.outline, width: 0.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPeso(total),
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  accountsAsync.maybeWhen(
                    data: (list) => Text(
                      '${list.length} accounts',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(kRadius12),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: cs.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
