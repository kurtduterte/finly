import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/utils/date_format.dart';
import 'package:finly/features/expenses/presentation/widgets/async_dropdown_field.dart';
import 'package:finly/features/expenses/presentation/widgets/expense_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseFormFields extends StatelessWidget {
  const ExpenseFormFields({
    required this.amountController,
    required this.descriptionController,
    required this.otherTypeController,
    required this.date,
    required this.categories,
    required this.accounts,
    required this.selectedCategory,
    required this.selectedAccount,
    required this.showOtherTypeField,
    required this.onPickDate,
    required this.onCategoryChanged,
    required this.onAccountChanged,
    super.key,
  });

  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final TextEditingController otherTypeController;
  final DateTime date;
  final AsyncValue<List<Category>> categories;
  final AsyncValue<List<Account>> accounts;
  final Category? selectedCategory;
  final Account? selectedAccount;
  final bool showOtherTypeField;
  final VoidCallback onPickDate;
  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<Account?> onAccountChanged;

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final amount = double.tryParse(value);
    if (amount == null) return 'Invalid amount';
    if (amount <= 0) return 'Must be greater than 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpenseTextFormField(
          controller: amountController,
          label: 'Amount',
          prefixText: '₱ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateAmount,
        ),
        const SizedBox(height: 16),
        ExpenseTextFormField(
          controller: descriptionController,
          label: 'Description',
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Date'),
          subtitle: Text(formatDate(date)),
          trailing: const Icon(Icons.calendar_today),
          onTap: onPickDate,
        ),
        AsyncDropdownField<Category>(
          asyncItems: categories,
          selectedValue: selectedCategory,
          label: 'Category',
          errorText: 'Failed to load categories',
          itemLabel: (category) => category.name,
          onChanged: onCategoryChanged,
        ),
        if (showOtherTypeField) ...[
          const SizedBox(height: 16),
          ExpenseTextFormField(
            controller: otherTypeController,
            label: 'Expense type',
            hintText: 'e.g. Pet care, Gift, Miscellaneous',
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
        ],
        const SizedBox(height: 16),
        AsyncDropdownField<Account>(
          asyncItems: accounts,
          selectedValue: selectedAccount,
          label: 'Account',
          errorText: 'Failed to load accounts',
          itemLabel: (account) => account.name,
          onChanged: onAccountChanged,
        ),
      ],
    );
  }
}
