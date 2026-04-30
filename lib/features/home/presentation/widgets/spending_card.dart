import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:flutter/material.dart';

class SpendingCard extends StatelessWidget {
  const SpendingCard({
    required this.totalCentavos,
    required this.monthLabel,
    super.key,
  });

  final int totalCentavos;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCardGradientStart, kCardGradientEnd],
        ),
        border: Border.all(color: cs.primaryContainer, width: 0.8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  monthLabel,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.trending_down_rounded, color: cs.primary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Spent',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatPeso(totalCentavos),
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
