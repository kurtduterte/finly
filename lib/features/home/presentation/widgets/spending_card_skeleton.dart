import 'package:finly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SpendingCardSkeleton extends StatelessWidget {
  const SpendingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 136,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(kRadius20),
          border: Border.all(color: cs.outline, width: 0.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
