import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({this.initial, super.key});
  final ExpenseWithDetails? initial;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _date;
  Category? _category;
  Account? _account;

  @override
  void initState() {
    super.initState();
    final e = widget.initial?.expense;
    _amountCtrl = TextEditingController(
      text: e != null ? (e.amountCentavos / 100).toStringAsFixed(2) : '',
    );
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _date = e?.date ?? DateTime.now();
    _category = widget.initial?.category;
    _account = widget.initial?.account;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Please select a category and account')),
      );
      return;
    }
    final centavos = (double.parse(_amountCtrl.text) * 100).round();
    final notifier = ref.read(expensesNotifierProvider.notifier);
    if (widget.initial == null) {
      await notifier.add(
        ExpensesCompanion.insert(
          amountCentavos: centavos,
          description: _descCtrl.text.trim(),
          date: _date,
          categoryId: _category!.id,
          accountId: _account!.id,
        ),
      );
    } else {
      await notifier.updateExpense(
        widget.initial!.expense.copyWith(
          amountCentavos: centavos,
          description: _descCtrl.text.trim(),
          date: _date,
          categoryId: _category!.id,
          accountId: _account!.id,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesListProvider);
    final accounts = ref.watch(accountsListProvider);
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
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = double.tryParse(v);
                if (n == null) return 'Invalid amount';
                if (n <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_formatDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            categories.when(
              data: (list) => DropdownButtonFormField<Category>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: list
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const Text('Failed to load categories'),
            ),
            const SizedBox(height: 16),
            accounts.when(
              data: (list) => DropdownButtonFormField<Account>(
                initialValue: _account,
                decoration: const InputDecoration(labelText: 'Account'),
                items: list
                    .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _account = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const Text('Failed to load accounts'),
            ),
          ],
        ),
      ),
    );
  }
}
