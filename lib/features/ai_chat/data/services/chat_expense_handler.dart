import 'package:drift/drift.dart';
import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/expenses/data/repositories/expenses_repository.dart';

class ChatExpenseHandler {
  const ChatExpenseHandler({required this.gemma, required this.expRepo});

  final GemmaService gemma;
  final ExpensesRepository expRepo;

  Future<String> handle({
    required String userMessage,
    required void Function(String buffer) onToken,
    required bool Function() isCancelled,
    String? contextMessage,
  }) async {
    final categories = await expRepo.getAllCategories();
    final accounts = await expRepo.getAllAccounts();
    final now = DateTime.now();
    final extractionInput = _pickExtractionInput(userMessage, contextMessage);
    final shouldRunAiExtraction = hasAmountHint(extractionInput);

    var parsed = tryRuleBasedExtract(userMessage, now, accounts: accounts);
    parsed ??= extractionInput == userMessage
        ? null
        : tryRuleBasedExtract(extractionInput, now, accounts: accounts);

    if (parsed == null && !shouldRunAiExtraction) {
      return 'Please include an amount and description, '
          'like: "coffee 260 lunch"';
    }

    if (shouldRunAiExtraction) {
      final aiParsed = await _extractWithAi(
        userMessage: extractionInput,
        categories: categories,
        accounts: accounts,
        today: now,
        fallbackDescription: parsed?.description ?? extractionInput,
        onToken: onToken,
        isCancelled: isCancelled,
      );
      if (isCancelled()) return '';
      parsed = aiParsed ?? parsed;
    }

    if (parsed == null) {
      return "Sorry, I couldn't extract the expense details. "
          'Try: "Add expense ₱150 for lunch"';
    }

    final category =
        matchCategory(categories, parsed.categoryName) ??
        categories.firstWhere(
          (c) => c.name == 'Other',
          orElse: () => categories.first,
        );
    final account =
        matchAccount(accounts, parsed.accountName) ??
        accounts.firstWhere(
          (a) => a.name == 'Cash',
          orElse: () => accounts.first,
        );

    await expRepo.addExpense(
      ExpensesCompanion(
        amountCentavos: Value(parsed.amountCentavos),
        description: Value(parsed.description),
        date: Value(parsed.date),
        categoryId: Value(category.id),
        accountId: Value(account.id),
      ),
    );

    final amount = (parsed.amountCentavos / 100).toStringAsFixed(2);
    return '✅ Expense saved!\n'
        '₱$amount – ${parsed.description}\n'
        '${category.name} · ${account.name}';
  }

  String _pickExtractionInput(String userMessage, String? contextMessage) {
    if (hasAmountHint(userMessage)) return userMessage;
    final context = contextMessage?.trim();
    if (context != null && context.isNotEmpty && hasAmountHint(context)) {
      return context;
    }
    return userMessage;
  }

  Future<ParsedExpense?> _extractWithAi({
    required String userMessage,
    required List<Category> categories,
    required List<Account> accounts,
    required DateTime today,
    required String fallbackDescription,
    required void Function(String buffer) onToken,
    required bool Function() isCancelled,
  }) async {
    final messages = buildExpenseExtractionPrompt(
      userMessage: userMessage,
      categories: categories,
      accounts: accounts,
      today: today,
    );
    final buffer = StringBuffer();

    await for (final token in gemma.streamMessages(messages)) {
      if (isCancelled()) return null;
      buffer.write(token);
      onToken(buffer.toString());
    }

    if (isCancelled()) return null;
    return parseExpenseResponse(
      buffer.toString(),
      fallbackDescription: fallbackDescription,
    );
  }
}
