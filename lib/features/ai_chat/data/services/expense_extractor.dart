import 'dart:convert';

import 'package:finly/ai/ai_message.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';

export 'package:finly/features/ai_chat/data/models/parsed_expense.dart';

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
  if (explicitPhrases.any(lower.contains)) return true;
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

List<AiMessage> buildExpenseExtractionPrompt({
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
      'Extract expense details from the user message. '
      'Respond ONLY with JSON, no other text.\n'
      'Rules:\n'
      '- amount: the number (e.g. 200, 150.50)\n'
      '- description: merchant, vendor, or item name '
      '(e.g. "mcdo"→"McDonald\'s", "jollibee"→"Jollibee", '
      '"lunch"→"Lunch"). REQUIRED — never leave empty.\n'
      '- category: best match from the list, or "Other"\n'
      '- account: best match from the list, or "Cash"\n'
      '- date: YYYY-MM-DD, use today if not mentioned\n\n'
      'Example: "add expense 200 mcdo" → '
      '{"amount":200.00,"description":"McDonald\'s",'
      '"category":"Food","account":"Cash","date":"$todayStr"}\n\n'
      'Categories: $catNames\n'
      'Accounts: $accNames\n'
      'Today: $todayStr\n\n'
      'User: $userMessage';
  return [AiMessage(text: prompt)];
}

ParsedExpense? parseExpenseResponse(
  String response, {
  String fallbackDescription = '',
}) {
  final match = RegExp(r'\{[^{}]+\}').firstMatch(response);
  if (match == null) return null;
  try {
    final data = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    final amountRaw = data['amount'] as num?;
    if (amountRaw == null || amountRaw <= 0) return null;
    final description =
        (data['description'] as String?)?.trim().isNotEmpty == true
            ? (data['description'] as String).trim()
            : fallbackDescription;
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

/// Fast rule-based extractor for simple patterns — no LLM needed.
/// Handles: "add expense 200 mcdo", "log expense ₱150 for lunch", etc.
ParsedExpense? tryRuleBasedExtract(String msg, DateTime today) {
  final explicit = RegExp(
    r'(?:add|log|record|new|save|track)\s+expense\s+'
    r'[₱]?(\d+(?:\.\d{1,2})?)'
    r'(?:\s+(?:for|at|on|from))?\s+(.+)',
    caseSensitive: false,
  );
  final implicit = RegExp(
    r'i\s+(?:spent|paid|bought)\s+'
    r'[₱]?(\d+(?:\.\d{1,2})?)'
    r'(?:\s+(?:for|at|on|from))?\s+(.+)',
    caseSensitive: false,
  );
  final m = explicit.firstMatch(msg.trim()) ?? implicit.firstMatch(msg.trim());
  if (m == null) return null;
  final amount = double.tryParse(m.group(1)!);
  if (amount == null || amount <= 0) return null;
  final desc = m.group(2)!.trim();
  if (desc.isEmpty) return null;
  return ParsedExpense(
    amountCentavos: (amount * 100).round(),
    description: desc,
    categoryName: 'Other',
    accountName: 'Cash',
    date: today,
  );
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
