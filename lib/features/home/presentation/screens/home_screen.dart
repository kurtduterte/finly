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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
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
          SliverToBoxAdapter(
            child: expensesAsync.when(
              loading: () => const SpendingCardSkeleton(),
              error: (_, _) => const SizedBox.shrink(),
              data: (expenses) {
                final thisMonth = expenses.where((e) {
                  final d = e.expense.date;
                  return d.year == now.year && d.month == now.month;
                });
                final total = thisMonth.fold<int>(
                  0,
                  (sum, e) => sum + e.expense.amountCentavos,
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SpendingCard(
                    totalCentavos: total,
                    monthLabel: formatMonthYear(now),
                  ),
                );
              },
            ),
          ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  expensesAsync.maybeWhen(
                    data: (e) => Text(
                      '${e.length} total',
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          expensesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('$e')),
            ),
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
