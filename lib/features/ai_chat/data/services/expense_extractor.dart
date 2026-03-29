import 'dart:convert';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class ParsedExpense {
  const ParsedExpense({
    required this.amountCentavos,
    required this.description,
    required this.categoryName,
    required this.accountName,
    required this.date,
  });
  final int amountCentavos;
  final String description;
  final String categoryName;
  final String accountName;
  final DateTime date;
}

bool isAddExpenseIntent(String msg) {
  final lower = msg.toLowerCase();
  const explicitPhrases = [
    'add expense',
    'log expense',
    'record expense',
    'new expense',
    'save expense',
    'track expense',
  ];
  if (explicitPhrases.any(lower.contains)) {
    return true;
  }
  if (['i spent', 'i paid', 'i bought'].any(lower.contains) &&
      RegExp(r'\d').hasMatch(lower)) {
    return true;
  }
  if (['add', 'log', 'record'].any(lower.contains) &&
      (lower.contains('₱') ||
          RegExp(r'\d+\s*(pesos?|php)').hasMatch(lower))) {
    return true;
  }
  return false;
}

List<Message> buildExpenseExtractionPrompt({
  required String userMessage,
  required List<Category> categories,
  required List<Account> accounts,
  required DateTime today,
}) {
  final catNames = categories.map((c) => c.name).join(', ');
  final accNames = accounts.map((a) => a.name).join(', ');
  final mm = today.month.toString().padLeft(2, '0');
  final dd = today.day.toString().padLeft(2, '0');
  final todayStr = '${today.year}-$mm-$dd';

  final prompt =
      'Extract expense details. Respond ONLY with JSON, no other text:\n'
      '{"amount":0.00,"description":"","category":"",'
      '"account":"","date":""}\n\n'
      'Categories: $catNames\n'
      'Accounts: $accNames\n'
      'Today: $todayStr (use if no date mentioned). '
      'Default category: Other. Default account: Cash.\n\n'
      'User: $userMessage';
  return [Message.text(text: prompt)];
}

ParsedExpense? parseExpenseResponse(String response) {
  final match = RegExp(r'\{[^{}]+\}').firstMatch(response);
  if (match == null) return null;
  try {
    final data = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    final amountRaw = data['amount'] as num?;
    if (amountRaw == null || amountRaw <= 0) return null;
    final description = (data['description'] as String?)?.trim() ?? '';
    if (description.isEmpty) return null;
    final categoryName = (data['category'] as String?)?.trim() ?? 'Other';
    final accountName = (data['account'] as String?)?.trim() ?? 'Cash';
    final dateStr = data['date'] as String?;
    final date =
        (dateStr != null ? DateTime.tryParse(dateStr) : null) ?? DateTime.now();
    return ParsedExpense(
      amountCentavos: (amountRaw.toDouble() * 100).round(),
      description: description,
      categoryName: categoryName,
      accountName: accountName,
      date: date,
    );
  } on FormatException {
    return null;
  }
}

Category? matchCategory(List<Category> cats, String name) {
  final lower = name.toLowerCase();
  for (final c in cats) {
    if (c.name.toLowerCase() == lower) return c;
  }
  for (final c in cats) {
    final cLower = c.name.toLowerCase();
    if (cLower.contains(lower) || lower.contains(cLower)) return c;
  }
  return null;
}

Account? matchAccount(List<Account> accs, String name) {
  final lower = name.toLowerCase();
  for (final a in accs) {
    if (a.name.toLowerCase() == lower) return a;
  }
  return null;
}

String buildExpenseContext(List<ExpenseWithDetails> expenses) {
  if (expenses.isEmpty) return '';
  final sb = StringBuffer('[Recent expenses]\n');
  for (final e in expenses) {
    final amount = (e.expense.amountCentavos / 100).toStringAsFixed(2);
    final d = e.expense.date;
    sb.writeln(
      '• ${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}'
      ' | ${e.category.name} (${e.account.name})'
      ' | ₱$amount — ${e.expense.description}',
    );
  }
  return sb.toString().trimRight();
}
