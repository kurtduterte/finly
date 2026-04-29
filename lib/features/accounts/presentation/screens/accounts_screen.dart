import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:finly/features/accounts/presentation/providers/accounts_providers.dart';
import 'package:finly/features/accounts/presentation/widgets/account_list_tile.dart';
import 'package:finly/features/accounts/presentation/widgets/edit_balance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const _order = ['cash', 'ewallet', 'bank'];

  void _showEditDialog(BuildContext context, Account account) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => EditBalanceDialog(account: account),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final total = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (accounts) {
          final grouped = <String, List<Account>>{};
          for (final a in accounts) {
            (grouped[a.type] ??= []).add(a);
          }
          final sections = _order
              .where(grouped.containsKey)
              .map((t) => (t, grouped[t]!))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _TotalBalanceHeader(totalCentavos: total),
              ),
              for (final (type, list) in sections) ...[
                SliverToBoxAdapter(
                  child: _SectionLabel(type: type),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => AccountListTile(
                      account: list[i],
                      onTap: () => _showEditDialog(context, list[i]),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _TotalBalanceHeader extends StatelessWidget {
  const _TotalBalanceHeader({required this.totalCentavos});
  final int totalCentavos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2B1A), Color(0xFF0D1F2D)],
          ),
          border: Border.all(color: AppColors.primaryContainer, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatPeso(totalCentavos),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.type});
  final String type;

  String get _label => switch (type) {
        'cash' => 'Cash',
        'ewallet' => 'E-Wallets',
        'bank' => 'Banks',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        _label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
