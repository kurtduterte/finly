import 'package:finly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.inversePrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(kRadius14),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: cs.onPrimary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Finly',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
