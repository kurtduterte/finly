import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/core/utils/currency_format.dart';
import 'package:flutter/material.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    required this.account,
    required this.onTap,
    super.key,
  });

  final Account account;
  final VoidCallback onTap;

  String get _typeLabel => switch (account.type) {
        'cash' => 'Cash',
        'ewallet' => 'E-Wallet',
        'bank' => 'Bank',
        _ => account.type,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = parseHexColor(account.color);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(kRadius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius14),
            border: Border.all(color: cs.outline, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _typeLabel,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatPeso(account.balanceCentavos),
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
