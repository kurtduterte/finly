import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/expenses/data/repositories/expenses_repository.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

const financeKeywords = [
  'expense', 'spend', 'spent', 'cost', 'buy', 'bought', 'purchase',
  'money', 'budget', 'total', 'how much', 'paid', 'pay',
  'transaction', 'account', 'balance', 'receipt', 'bill',
  'price', 'debt', 'saving', 'income', 'salary',
];

const _system =
    'You are Mich, a helpful personal finance assistant. Be concise.';

Future<List<Message>> buildChatMessages({
  required String userMessage,
  required List<ChatMessage> history,
  required ExpensesRepository expRepo,
}) async {
  var expenseBlock = '';
  if (_isFinanceQuery(userMessage)) {
    try {
      expenseBlock = buildExpenseContext(await expRepo.getRecentWithDetails());
    } on Exception {
      // Proceed without expense context
    }
  }

  final turns = <Message>[];
  if (history.isEmpty) {
    final content = expenseBlock.isEmpty
        ? '$_system\n\n$userMessage'
        : '$_system\n\n$expenseBlock\n\n$userMessage';
    turns.add(Message.text(text: content));
  } else {
    final first = history.first;
    turns.add(Message.text(
      text: '$_system\n\n${first.messageText}',
      isUser: first.isUser == 1,
    ));
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
  return financeKeywords.any(lower.contains);
}
