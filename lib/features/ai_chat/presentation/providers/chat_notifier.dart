import 'dart:async';

import 'package:finly/ai/gemma_service_provider.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
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

    if (convId == null) {
      convId = await repo.createConversation();
      final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
      unawaited(repo.updateTitle(convId, title));
      state = state.copyWith(conversationId: convId);
    }

    await repo.addMessage(conversationId: convId, text: text, isUser: true);
    state = state.copyWith(isGenerating: true, streamingBuffer: '');

    try {
      final augmented = await _buildPrompt(text);
      final buffer = StringBuffer();
      await for (final token
          in ref.read(gemmaServiceProvider).streamResponse(augmented)) {
        buffer.write(token);
        state = state.copyWith(streamingBuffer: buffer.toString());
      }
      await repo.addMessage(
        conversationId: convId,
        text: buffer.toString(),
        isUser: false,
      );
    } finally {
      state = state.copyWith(isGenerating: false, streamingBuffer: '');
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
        final amount = (e.expense.amountCentavos / 100).toStringAsFixed(2);
        final d = e.expense.date;
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        final date = '${d.year}-$m-$day';
        final line =
            '• $date | ${e.category.name}'
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

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
