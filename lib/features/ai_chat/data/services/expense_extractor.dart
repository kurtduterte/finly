import 'dart:convert';

import 'package:finly/ai/ai_message.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/expenses_dao.dart';
import 'package:finly/features/ai_chat/data/models/parsed_expense.dart';

export 'package:finly/features/ai_chat/data/models/parsed_expense.dart';

bool isAddExpenseIntent(String msg) {
  final lower = msg.toLowerCase();
  final hasExplicitExpensePhrase = _containsAny(lower, _explicitExpensePhrases);
  final soundsLikeSpentStatement =
      _containsAny(lower, _spentActionPhrases) && _digitPattern.hasMatch(lower);
  final looksLikeQuickCommandWithAmount =
      _containsAny(lower, _quickActionPhrases) &&
      (lower.contains('₱') || _pesoPhpPattern.hasMatch(lower));

  return hasExplicitExpensePhrase ||
      soundsLikeSpentStatement ||
      looksLikeQuickCommandWithAmount ||
      _looksLikeQuickExpenseEntry(lower);
}

bool hasAmountHint(String msg) => _amountPattern.hasMatch(msg);

List<AiMessage> buildExpenseExtractionPrompt({
  required String userMessage,
  required List<Category> categories,
  required List<Account> accounts,
  required DateTime today,
}) {
  final todayStr = _formatYmd(today);
  final prompt = _buildExtractionPromptText(
    userMessage: userMessage,
    categoryNames: categories.map((c) => c.name).join(', '),
    accountNames: accounts.map((a) => a.name).join(', '),
    todayStr: todayStr,
  );
  return <AiMessage>[AiMessage(text: prompt)];
}

ParsedExpense? parseExpenseResponse(
  String response, {
  String fallbackDescription = '',
}) {
  final jsonBlock = _jsonObjectPattern.firstMatch(response)?.group(0);
  if (jsonBlock == null) return null;

  try {
    final data = jsonDecode(jsonBlock) as Map<String, dynamic>;
    return _toParsedExpense(data, fallbackDescription: fallbackDescription);
  } on FormatException {
    return null;
  }
}

ParsedExpense? tryRuleBasedExtract(
  String msg,
  DateTime today, {
  List<Account> accounts = const [],
}) {
  final normalized = msg.trim();
  final amountMatch = _amountCapturePattern.firstMatch(normalized);
  if (amountMatch == null) return null;

  final amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', ''));
  if (amount == null || amount <= 0) return null;

  var description = _buildRuleBasedDescription(
    message: normalized,
    rawAmount: amountMatch.group(0)!,
  );

  final accountName = _findAccountNameHint(normalized, accounts);
  if (accountName != null) {
    description = _stripAccountHint(description, accountName);
  }

  if (description.isEmpty) return null;

  return ParsedExpense(
    amountCentavos: (amount * 100).round(),
    description: description,
    categoryName: _defaultCategoryName,
    accountName: accountName ?? _defaultAccountName,
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
  final buffer = StringBuffer('[Recent expenses]\n');
  for (final expense in expenses) {
    final amount = (expense.expense.amountCentavos / 100).toStringAsFixed(2);
    buffer.writeln(
      '• ${_formatYmd(expense.expense.date)}'
      ' | ${expense.category.name} (${expense.account.name})'
      ' | ₱$amount — ${expense.expense.description}',
    );
  }
  return buffer.toString().trimRight();
}

bool _looksLikeQuickExpenseEntry(String lower) {
  if (!hasAmountHint(lower)) return false;
  if (lower.contains('?')) return false;

  if (_containsAny(lower, _notExpenseHints)) return false;

  final withoutAmount = lower.replaceFirst(_amountPattern, '');
  final words = _tokenizeWords(withoutAmount);
  return words.isNotEmpty && words.length <= 5;
}

const _defaultCategoryName = 'Other';
const _defaultAccountName = 'Cash';
const int _sqliteInt64Max = 9223372036854775807;

const _explicitExpensePhrases = <String>[
  'add expense',
  'log expense',
  'record expense',
  'new expense',
  'save expense',
  'track expense',
];

const _spentActionPhrases = <String>['i spent', 'i paid', 'i bought'];
const _quickActionPhrases = <String>['add', 'log', 'record'];

const _notExpenseHints = <String>[
  'income',
  'salary',
  'budget',
  'balance',
  'account',
  'saving',
  'debt',
  'total',
  'how much',
];

final _digitPattern = RegExp(r'\d');
final _pesoPhpPattern = RegExp(r'\d+\s*(pesos?|php)');
final _amountPattern = RegExp(r'[₱]?\s*\d+(?:[.,]\d{1,2})?');
final _amountCapturePattern = RegExp(r'[₱]?\s*(\d+(?:[.,]\d{1,2})?)');
final _jsonObjectPattern = RegExp(r'\{[^{}]+\}');
final _nonAlphaPattern = RegExp(r'[^a-z\s]');
final _multiSpacePattern = RegExp(r'\s+');

final _expensePrefixPattern = RegExp(
  r'^(?:add|log|record|new|save|track)\s+expense\b',
  caseSensitive: false,
);
final _spentPrefixPattern = RegExp(
  r'^i\s+(?:spent|paid|bought)\b',
  caseSensitive: false,
);
final _prepPrefixPattern = RegExp(
  r'^(?:for|at|on|from)\s+',
  caseSensitive: false,
);

double? _parseAmount(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '').trim());
  }
  return null;
}

String _buildExtractionPromptText({
  required String userMessage,
  required String categoryNames,
  required String accountNames,
  required String todayStr,
}) {
  return 'Extract expense details from the user message. '
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
      'Categories: $categoryNames\n'
      'Accounts: $accountNames\n'
      'Today: $todayStr\n\n'
      'User: $userMessage';
}

ParsedExpense? _toParsedExpense(
  Map<String, dynamic> data, {
  required String fallbackDescription,
}) {
  final amount = _parseAmount(data['amount']);
  if (amount == null || !amount.isFinite || amount <= 0) return null;

  final amountCentavos = amount * 100;
  if (!amountCentavos.isFinite || amountCentavos > _sqliteInt64Max) return null;

  final description = _readDescription(
    rawDescription: data['description'],
    fallbackDescription: fallbackDescription,
  );
  if (description == null) return null;

  final categoryName =
      (data['category'] as String?)?.trim() ?? _defaultCategoryName;
  final accountName =
      (data['account'] as String?)?.trim() ?? _defaultAccountName;
  final date = _readDate(data['date']);

  return ParsedExpense(
    amountCentavos: amountCentavos.round(),
    description: description,
    categoryName: categoryName,
    accountName: accountName,
    date: date,
  );
}

String? _readDescription({
  required Object? rawDescription,
  required String fallbackDescription,
}) {
  final parsedDescription = (rawDescription as String?)?.trim();
  final description = parsedDescription != null && parsedDescription.isNotEmpty
      ? parsedDescription
      : fallbackDescription.trim();
  if (description.isEmpty) return null;
  return description;
}

DateTime _readDate(Object? rawDate) {
  final dateStr = rawDate as String?;
  return (dateStr != null ? DateTime.tryParse(dateStr) : null) ??
      DateTime.now();
}

String _buildRuleBasedDescription({
  required String message,
  required String rawAmount,
}) {
  var description = message.replaceFirst(rawAmount, ' ');
  description = _normalizeWhitespace(description);
  description = description.replaceFirst(_expensePrefixPattern, '').trim();
  description = description.replaceFirst(_spentPrefixPattern, '').trim();
  description = description.replaceFirst(_prepPrefixPattern, '').trim();
  return description;
}

String? _findAccountNameHint(String message, List<Account> accounts) {
  if (accounts.isEmpty) return null;
  final ordered = [...accounts]
    ..sort((a, b) => b.name.length.compareTo(a.name.length));

  for (final account in ordered) {
    final pattern = RegExp(
      '(^|[^a-z0-9])${RegExp.escape(account.name)}([^a-z0-9]|\$)',
      caseSensitive: false,
    );
    if (pattern.hasMatch(message)) return account.name;
  }
  return null;
}

String _stripAccountHint(String description, String accountName) {
  final pattern = RegExp(
    '(^|\\s)${RegExp.escape(accountName)}(?=\\s|\$)',
    caseSensitive: false,
  );
  final withoutAccount = description.replaceAll(pattern, ' ');
  return _normalizeWhitespace(withoutAccount);
}

List<String> _tokenizeWords(String value) {
  final cleaned = value.replaceAll(_nonAlphaPattern, ' ').trim();
  if (cleaned.isEmpty) return const <String>[];

  return cleaned.split(_multiSpacePattern)..removeWhere((word) => word.isEmpty);
}

bool _containsAny(String value, List<String> hints) {
  for (final hint in hints) {
    if (value.contains(hint)) return true;
  }
  return false;
}

String _normalizeWhitespace(String value) {
  return value.replaceAll(_multiSpacePattern, ' ').trim();
}

String _formatYmd(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
