import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/core/utils/date_format.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:finly/features/home/presentation/widgets/accounts_summary_card.dart';
import 'package:finly/features/home/presentation/widgets/empty_transactions.dart';
import 'package:finly/features/home/presentation/widgets/home_header.dart';
import 'package:finly/features/home/presentation/widgets/quick_actions.dart';
import 'package:finly/features/home/presentation/widgets/spending_card.dart';
import 'package:finly/features/home/presentation/widgets/spending_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  int _monthlyTotal(List<ExpenseWithDetails> expenses, DateTime now) {
    return expenses
        .where((item) {
          final date = item.expense.date;
          return date.year == now.year && date.month == now.month;
        })
        .fold<int>(0, (sum, item) => sum + item.expense.amountCentavos);
  }

  SliverToBoxAdapter _buildSpendingSection(
    AsyncValue<List<ExpenseWithDetails>> expensesAsync,
    DateTime now,
  ) {
    return SliverToBoxAdapter(
      child: expensesAsync.when(
        loading: () => const SpendingCardSkeleton(),
        error: (_, _) => const SizedBox.shrink(),
        data: (expenses) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SpendingCard(
            totalCentavos: _monthlyTotal(expenses, now),
            monthLabel: formatMonthYear(now),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecentHeader(
    AsyncValue<List<ExpenseWithDetails>> expensesAsync,
    ColorScheme colorScheme,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Row(
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            expensesAsync.maybeWhen(
              data: (expenses) => Text(
                '${expenses.length} total',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(AsyncValue<List<ExpenseWithDetails>> expensesAsync) {
    return expensesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) =>
          SliverToBoxAdapter(child: Center(child: Text('$error'))),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const SliverToBoxAdapter(child: EmptyTransactions());
        }
        final recent = expenses.take(8).toList();
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: recent.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => ExpenseListItem(item: recent[i]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).value;
    final expensesAsync = ref.watch(expensesListProvider);
    final now = DateTime.now();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: HomeHeader(
                displayName: user?.displayName ?? user?.email,
              ),
            ),
          ),
          _buildSpendingSection(expensesAsync, now),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: AccountsSummaryCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: QuickActions(),
            ),
          ),
          _buildRecentHeader(expensesAsync, colorScheme),
          _buildRecentList(expensesAsync),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
