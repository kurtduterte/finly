import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:finly/features/expenses/presentation/widgets/expense_form_fields.dart';
import 'package:finly/features/scan/data/models/scan_prefill.dart';
import 'package:finly/features/sync/presentation/providers/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:finly/features/scan/data/models/scan_prefill.dart';

(String, String)? _parseOther(String description) {
  final m = RegExp(r'^\[(.+?)\] (.*)$').firstMatch(description);
  return m != null ? (m.group(1)!, m.group(2)!) : null;
}

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({this.initial, this.prefill, super.key});
  final ExpenseWithDetails? initial;
  final ScanPrefill? prefill;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _otherTypeCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _date;
  Category? _category;
  Account? _account;

  bool get _isOther => _category?.name == 'Other';

  @override
  void initState() {
    super.initState();
    final e = widget.initial?.expense;
    final p = widget.prefill;
    _amountCtrl = TextEditingController(
      text: e != null
          ? (e.amountCentavos / 100).toStringAsFixed(2)
          : p?.amountCentavos != null
          ? (p!.amountCentavos! / 100).toStringAsFixed(2)
          : '',
    );
    _date = e?.date ?? p?.date ?? DateTime.now();
    _category = widget.initial?.category;
    _account = widget.initial?.account;

    var otherType = '';
    var desc = e?.description ?? p?.description ?? '';
    if (_category?.name == 'Other' && desc.isNotEmpty) {
      final parsed = _parseOther(desc);
      if (parsed != null) (otherType, desc) = parsed;
    }
    _otherTypeCtrl = TextEditingController(text: otherType);
    _descCtrl = TextEditingController(text: desc);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _otherTypeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyPrefillSelections(
    List<Category> categories,
    List<Account> accounts,
  ) {
    if (_category != null && _account != null) return;
    final prefill = widget.prefill;
    if (prefill == null) return;
    if (_category == null && prefill.categoryName != null) {
      _category = _findPrefillCategory(categories, prefill.categoryName!);
    }
    if (_account == null && prefill.accountName != null) {
      _account = _findPrefillAccount(accounts, prefill.accountName!);
    }
  }

  Category _findPrefillCategory(
    List<Category> categories,
    String categoryName,
  ) {
    final lower = categoryName.toLowerCase();
    return categories.firstWhere(
      (category) => category.name.toLowerCase() == lower,
      orElse: () => categories.firstWhere(
        (category) =>
            category.name.toLowerCase().contains(lower) ||
            lower.contains(category.name.toLowerCase()),
        orElse: () => categories.first,
      ),
    );
  }

  Account _findPrefillAccount(List<Account> accounts, String accountName) {
    final lower = accountName.toLowerCase();
    return accounts.firstWhere(
      (account) => account.name.toLowerCase() == lower,
      orElse: () => accounts.first,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a category and account')),
      );
      return;
    }

    final amountCentavos = (double.parse(_amountCtrl.text) * 100).round();
    final type = _otherTypeCtrl.text.trim();
    final descriptionText = _descCtrl.text.trim();
    final description = _isOther ? '[$type] $descriptionText' : descriptionText;
    final notifier = ref.read(expensesNotifierProvider.notifier);

    if (widget.initial == null) {
      await notifier.add(
        ExpensesCompanion.insert(
          amountCentavos: amountCentavos,
          description: description,
          date: _date,
          categoryId: _category!.id,
          accountId: _account!.id,
          receiptId: Value(widget.prefill?.receiptId),
        ),
      );
    } else {
      await notifier.updateExpense(
        widget.initial!.expense.copyWith(
          amountCentavos: amountCentavos,
          description: description,
          date: _date,
          categoryId: _category!.id,
          accountId: _account!.id,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _onCategoryChanged(Category? category) => setState(() {
    if (category?.name != 'Other') _otherTypeCtrl.clear();
    _category = category;
  });

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesListProvider);
    final accounts = ref.watch(accountsListProvider);

    if (categories.hasValue && accounts.hasValue) {
      _applyPrefillSelections(categories.value!, accounts.value!);
    }

    ref.listen(syncNotifierProvider, (prev, next) {
      if (prev != null && next.isSuccess && !prev.isSuccess) {
        unawaited(
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sync Successful'),
              content: const Text(
                'Your expenses have been synced to the Database.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Add Expense' : 'Edit Expense'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExpenseFormFields(
              amountController: _amountCtrl,
              descriptionController: _descCtrl,
              otherTypeController: _otherTypeCtrl,
              date: _date,
              categories: categories,
              accounts: accounts,
              selectedCategory: _category,
              selectedAccount: _account,
              showOtherTypeField: _isOther,
              onPickDate: _pickDate,
              onCategoryChanged: _onCategoryChanged,
              onAccountChanged: (v) => setState(() => _account = v),
            ),
          ],
        ),
      ),
    );
  }
}
