import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/widgets/chat_bubble.dart';
import 'package:finly/features/ai_chat/presentation/widgets/typing_greeting_bubble.dart';
import 'package:finly/features/ai_chat/presentation/widgets/typing_indicator_bubble.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    required this.messages,
    required this.chatState,
    required this.scrollController,
    super.key,
  });
  final List<ChatMessage> messages;
  final ChatState chatState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (chatState.isGenerating ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 1 + itemCount,
      itemBuilder: (context, i) {
        if (i == 0) {
          return TypingGreetingBubble(
            animate: chatState.conversationId == null,
          );
        }
        final msgIndex = i - 1;
        if (msgIndex < messages.length) {
          final msg = messages[msgIndex];
          return ChatBubble(text: msg.messageText, isUser: msg.isUser == 1);
        }
        return chatState.streamingBuffer.isNotEmpty
            ? ChatBubble(text: chatState.streamingBuffer, isUser: false)
            : const TypingIndicatorBubble();
      },
    );
  }
}
