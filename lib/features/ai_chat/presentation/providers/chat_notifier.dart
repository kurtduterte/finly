import 'dart:async';

import 'package:finly/ai/gemma_service.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/repositories/chat_repository.dart';
import 'package:finly/features/ai_chat/data/services/chat_expense_handler.dart';
import 'package:finly/features/ai_chat/data/services/chat_message_builder.dart';
import 'package:finly/features/ai_chat/data/services/expense_extractor.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_state.dart';
import 'package:finly/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:finly/features/ai_chat/presentation/providers/chat_state.dart';
part 'chat_notifier_message_flow.dart';

class ChatNotifier extends Notifier<ChatState> with _ChatNotifierMessageFlow {
  @override
  ChatState build() => const ChatState();

  void setConversation(int? id) => state = ChatState(conversationId: id);

  Future<void> deleteConversation(int id) async {
    await ref.read(chatRepositoryProvider).deleteConversation(id);
    if (state.conversationId == id) state = const ChatState();
  }

  Future<void> renameConversation(int id, String title) {
    return ref.read(chatRepositoryProvider).updateTitle(id, title);
  }

  Future<void> sendMessage(String text) async {
    if (state.isGenerating) return;

    final context = await _prepareMessageContext(text);
    await _sendUserMessage(context, text);
    await _receiveMessage(context, text);
  }

  @override
  Future<String> _streamConversation(
    String userMessage,
    List<ChatMessage> history,
    int convId,
  ) async {
    final messages = await buildChatMessages(
      userMessage: userMessage,
      history: history,
      expRepo: ref.read(expensesRepositoryProvider),
    );
    final buffer = StringBuffer();
    await for (final token
        in ref.read(gemmaServiceProvider).streamMessages(messages)) {
      if (state.conversationId != convId) return '';
      buffer.write(token);
      state = state.copyWith(streamingBuffer: buffer.toString());
    }
    return buffer.toString();
  }

  @override
  Future<String> _handleAddExpense(
    String userMessage,
    int convId, {
    String? contextMessage,
  }) async {
    final handler = ChatExpenseHandler(
      gemma: ref.read(gemmaServiceProvider),
      expRepo: ref.read(expensesRepositoryProvider),
    );

    final aiMessage = await handler.handle(
      userMessage: userMessage,
      contextMessage: contextMessage,
      onToken: (buf) {
        if (state.conversationId == convId) {
          state = state.copyWith(streamingBuffer: buf);
        }
      },
      isCancelled: () => state.conversationId != convId,
    );
    return aiMessage;
  }

  @override
  String? _latestUserMessage(List<ChatMessage> history) {
    for (final msg in history.reversed) {
      if (msg.isUser == 1) return msg.messageText;
    }
    return null;
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
