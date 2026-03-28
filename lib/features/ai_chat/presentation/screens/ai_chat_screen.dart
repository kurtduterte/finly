import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({this.conversationId, super.key});
  final int? conversationId;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(
        () => ref
            .read(chatNotifierProvider.notifier)
            .setConversation(widget.conversationId),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    unawaited(ref.read(chatNotifierProvider.notifier).sendMessage(text));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final convId = chatState.conversationId;

    ref.listen<ChatState>(chatNotifierProvider, (_, _) => _scrollToBottom());

    final messagesAsync = convId != null
        ? ref.watch(conversationMessagesProvider(convId))
        : const AsyncData<List<ChatMessage>>([]);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                final hasStreaming = chatState.isGenerating &&
                    chatState.streamingBuffer.isNotEmpty;
                final itemCount =
                    messages.length + (hasStreaming ? 1 : 0);

                if (itemCount == 0) {
                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: const [
                      _ChatBubble(
                        text: 'Hi! How can I help you with your Finances?',
                        isUser: false,
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    if (i < messages.length) {
                      final msg = messages[i];
                      return _ChatBubble(
                        text: msg.messageText,
                        isUser: msg.isUser == 1,
                      );
                    }
                    return _ChatBubble(
                      text: chatState.streamingBuffer,
                      isUser: false,
                    );
                  },
                );
              },
            ),
          ),
          _InputRow(
            controller: _textController,
            onSend: _send,
            enabled: !chatState.isGenerating,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text.isEmpty ? '…' : text,
          style: TextStyle(
            color: isUser ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: const InputDecoration(
                  hintText: 'Ask something…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
