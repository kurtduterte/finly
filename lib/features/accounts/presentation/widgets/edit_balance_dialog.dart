import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/theme/app_colors.dart';
import 'package:finly/features/accounts/presentation/providers/accounts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditBalanceDialog extends ConsumerStatefulWidget {
  const EditBalanceDialog({required this.account, super.key});
  final Account account;

  @override
  ConsumerState<EditBalanceDialog> createState() => _EditBalanceDialogState();
}

class _EditBalanceDialogState extends ConsumerState<EditBalanceDialog> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final amount = widget.account.balanceCentavos / 100;
    _ctrl = TextEditingController(
      text: widget.account.balanceCentavos > 0
          ? amount.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) return;
    setState(() => _saving = true);
    final centavos = (parsed * 100).round();
    await ref.read(accountsRepositoryProvider).updateAccount(
          widget.account.copyWith(balanceCentavos: centavos),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: Text(
        widget.account.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Balance',
          prefixText: '₱ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
