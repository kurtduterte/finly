import 'dart:async';

import 'package:drift/drift.dart';
import 'package:finly/ai/gemma_service_provider.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatState {
  const ChatState({
    this.conversationId,
    this.isGenerating = false,
    this.streamingBuffer = '',
  });
  final int? conversationId;
  final bool isGenerating;
  final String streamingBuffer;

  ChatState copyWith({
    bool clearConversationId = false,
    int? conversationId,
    bool? isGenerating,
    String? streamingBuffer,
  }) {
    return ChatState(
      conversationId: clearConversationId
          ? null
          : conversationId ?? this.conversationId,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingBuffer: streamingBuffer ?? this.streamingBuffer,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  void setConversation(int? id) => state = ChatState(conversationId: id);

  Future<void> sendMessage(String text) async {
    if (state.isGenerating) return;

    final repo = ref.read(chatRepositoryProvider);
    var convId = state.conversationId;

    // Load history before adding the new message
    final history = convId != null
        ? await repo.getMessages(convId)
        : <ChatMessage>[];

    if (convId == null) {
      convId = await repo.createConversation();
      final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
      unawaited(repo.updateTitle(convId, title));
      state = state.copyWith(conversationId: convId);
    }

    await repo.addMessage(conversationId: convId, text: text, isUser: true);
    state = state.copyWith(isGenerating: true, streamingBuffer: '');

    try {
      if (isAddExpenseIntent(text)) {
        await _handleAddExpense(text, convId);
      } else {
        final messages = await _buildMessages(text, history);
        final buffer = StringBuffer();
        await for (final token
            in ref.read(gemmaServiceProvider).streamMessages(messages)) {
          // Stop updating UI if the user has switched to another conversation
          if (state.conversationId != convId) return;
          buffer.write(token);
          state = state.copyWith(streamingBuffer: buffer.toString());
        }
        if (state.conversationId != convId) return;
        await repo.addMessage(
          conversationId: convId,
          text: buffer.toString(),
          isUser: false,
        );
      }
    } on Exception catch (e) {
      if (state.conversationId != convId) return;
      await repo.addMessage(
        conversationId: convId,
        text: 'Sorry, something went wrong: $e',
        isUser: false,
      );
    } finally {
      if (state.conversationId == convId) {
        state = state.copyWith(isGenerating: false, streamingBuffer: '');
      }
    }
  }

  Future<void> _handleAddExpense(String userMessage, int convId) async {
    final expRepo = ref.read(expensesRepositoryProvider);
    final categories = await expRepo.getAllCategories();
    final accounts = await expRepo.getAllAccounts();

    final messages = buildExpenseExtractionPrompt(
      userMessage: userMessage,
      categories: categories,
      accounts: accounts,
      today: DateTime.now(),
    );

    final buffer = StringBuffer();
    await for (final token
        in ref.read(gemmaServiceProvider).streamMessages(messages)) {
      if (state.conversationId != convId) return;
      buffer.write(token);
      state = state.copyWith(streamingBuffer: buffer.toString());
    }
    if (state.conversationId != convId) return;

    final parsed = parseExpenseResponse(buffer.toString());
    final String aiMessage;

    if (parsed != null) {
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
      aiMessage =
          '✅ Expense saved!\n'
          '₱$amount – ${parsed.description}\n'
          '${category.name} · ${account.name}';
    } else {
      aiMessage =
          "Sorry, I couldn't extract the expense details. "
          'Try: "Add expense ₱150 for lunch"';
    }

    await ref
        .read(chatRepositoryProvider)
        .addMessage(
          conversationId: convId,
          text: aiMessage,
          isUser: false,
        );
  }

  /// Builds a list of chat turns for the Gemma multi-turn API.
  ///
  /// Expense context is only injected when [userMessage] contains
  /// finance-related keywords, preventing the model from regurgitating
  /// expense data for unrelated queries like "hello".
  Future<List<Message>> _buildMessages(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    const system =
        'You are Mich, a helpful personal finance assistant. Be concise.';

    var expenseBlock = '';
    if (_isFinanceQuery(userMessage)) {
      try {
        final expenses = await ref
            .read(expensesRepositoryProvider)
            .getRecentWithDetails();
        expenseBlock = buildExpenseContext(expenses);
      } on Exception {
        // Proceed without expense context
      }
    }

    final turns = <Message>[];

    if (history.isEmpty) {
      // First ever message: combine system + optional expenses + user text
      final content = expenseBlock.isEmpty
          ? '$system\n\n$userMessage'
          : '$system\n\n$expenseBlock\n\n$userMessage';
      turns.add(Message.text(text: content));
    } else {
      // Multi-turn: prepend system to the first historical message, then
      // replay history, then add the current user message.
      final first = history.first;
      turns.add(
        Message.text(
          text: '$system\n\n${first.messageText}',
          isUser: first.isUser == 1,
        ),
      );
      for (final msg in history.skip(1)) {
        turns.add(Message.text(text: msg.messageText, isUser: msg.isUser == 1));
      }
      final currentContent = expenseBlock.isEmpty
          ? userMessage
          : '$expenseBlock\n\n$userMessage';
      turns.add(Message.text(text: currentContent));
    }

    return turns;
  }

  bool _isFinanceQuery(String msg) {
    final lower = msg.toLowerCase();
    return _financeKeywords.any(lower.contains);
  }

  static const _financeKeywords = [
    'expense',
    'spend',
    'spent',
    'cost',
    'buy',
    'bought',
    'purchase',
    'money',
    'budget',
    'total',
    'how much',
    'paid',
    'pay',
    'transaction',
    'account',
    'balance',
    'receipt',
    'bill',
    'price',
    'debt',
    'saving',
    'income',
    'salary',
  ];
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
