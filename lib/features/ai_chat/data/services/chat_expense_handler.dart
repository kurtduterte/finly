import 'package:drift/drift.dart';
import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/expenses/data/repositories/expenses_repository.dart';

/// Handles the "add expense" intent in chat by extracting and persisting
/// the expense, then returning an AI reply message.
class ChatExpenseHandler {
  const ChatExpenseHandler({required this.gemma, required this.expRepo});

  final GemmaService gemma;
  final ExpensesRepository expRepo;

  /// Streams token updates via [onToken]. Returns the final AI reply or ''
  /// if cancelled.
  Future<String> handle({
    required String userMessage,
    required void Function(String buffer) onToken,
    required bool Function() isCancelled,
  }) async {
    final categories = await expRepo.getAllCategories();
    final accounts = await expRepo.getAllAccounts();
    final now = DateTime.now();

    // Fast path: regex extraction — no LLM needed for simple patterns.
    var parsed = tryRuleBasedExtract(userMessage, now);

    // Slow path: ask Gemma to extract structured data.
    if (parsed == null) {
      final messages = buildExpenseExtractionPrompt(
        userMessage: userMessage,
        categories: categories,
        accounts: accounts,
        today: now,
      );
      final buffer = StringBuffer();
      await for (final token in gemma.streamMessages(messages)) {
        if (isCancelled()) return '';
        buffer.write(token);
        onToken(buffer.toString());
      }
      if (isCancelled()) return '';
      parsed = parseExpenseResponse(
        buffer.toString(),
        fallbackDescription: userMessage,
      );
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
}
