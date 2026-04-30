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

class ChatNotifier extends Notifier<ChatState> {
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

    final repo = ref.read(chatRepositoryProvider);
    var convId = state.conversationId;

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
        await _handleAddExpense(text, convId, repo);
      } else {
        final aiText = await _streamConversation(text, history, convId);
        if (state.conversationId != convId) return;
        await repo.addMessage(
          conversationId: convId,
          text: aiText,
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

  Future<void> _handleAddExpense(
    String userMessage,
    int convId,
    ChatRepository repo,
  ) async {
    final handler = ChatExpenseHandler(
      gemma: ref.read(gemmaServiceProvider),
      expRepo: ref.read(expensesRepositoryProvider),
    );

    final aiMessage = await handler.handle(
      userMessage: userMessage,
      onToken: (buf) {
        if (state.conversationId == convId) {
          state = state.copyWith(streamingBuffer: buf);
        }
      },
      isCancelled: () => state.conversationId != convId,
    );
    if (aiMessage.isEmpty || state.conversationId != convId) return;
    await repo.addMessage(
      conversationId: convId,
      text: aiMessage,
      isUser: false,
    );
  }

}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
