import 'package:finly/ai/gemma_service_provider.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  ChatMessage copyWith({String? text}) =>
      ChatMessage(text: text ?? this.text, isUser: isUser);
}

class ChatState {
  const ChatState({this.messages = const [], this.isGenerating = false});
  final List<ChatMessage> messages;
  final bool isGenerating;

  ChatState copyWith({List<ChatMessage>? messages, bool? isGenerating}) =>
      ChatState(
        messages: messages ?? this.messages,
        isGenerating: isGenerating ?? this.isGenerating,
      );
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  Future<void> sendMessage(String text) async {
    if (state.isGenerating) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: text, isUser: true),
        const ChatMessage(text: '', isUser: false),
      ],
      isGenerating: true,
    );

    try {
      final augmented = await _buildPrompt(text);
      await for (final token
          in ref.read(gemmaServiceProvider).streamResponse(augmented)) {
        final msgs = List<ChatMessage>.from(state.messages);
        msgs[msgs.length - 1] = msgs.last.copyWith(
          text: msgs.last.text + token,
        );
        state = state.copyWith(messages: msgs);
      }
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<String> _buildPrompt(String userMessage) async {
    try {
      final expenses = await ref
          .read(expensesRepositoryProvider)
          .getRecentWithDetails();

      if (expenses.isEmpty) return userMessage;

      final buffer = StringBuffer()
        ..writeln('[Financial context]')
        ..writeln('Recent expenses (newest first):');

      for (final e in expenses) {
        final amount =
            (e.expense.amountCentavos / 100).toStringAsFixed(2);
        final d = e.expense.date;
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        final date = '${d.year}-$m-$day';
        final line = '• $date | ${e.category.name}'
            ' (${e.account.name}) | ₱$amount'
            ' — ${e.expense.description}';
        buffer.writeln(line);
      }

      buffer
        ..writeln()
        ..writeln("Answer the user's question using this data if relevant.")
        ..writeln('User: $userMessage');

      return buffer.toString();
    } on Exception {
      return userMessage;
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
