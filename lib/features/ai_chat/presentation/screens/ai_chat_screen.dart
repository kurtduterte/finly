import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/widgets/chat_input_row.dart';
import 'package:finly/features/ai_chat/presentation/widgets/message_list.dart';
import 'package:finly/features/model_setup/presentation/providers/gemma_setup_notifier.dart';
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

  Future<void> _confirmAndDeleteChat(int convId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text(
          'This will permanently delete the conversation and all its messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(chatNotifierProvider.notifier).deleteConversation(convId);
    if (mounted) Navigator.pop(context);
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
    final gemmaState = ref.watch(gemmaSetupProvider);
    final convId = chatState.conversationId;

    ref.listen<ChatState>(chatNotifierProvider, (_, _) => _scrollToBottom());

    final messagesAsync = convId != null
        ? ref.watch(conversationMessagesProvider(convId))
        : const AsyncData<List<ChatMessage>>([]);

    final modelReady = gemmaState is GemmaSetupReady;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mich'),
        actions: [
          if (convId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete chat',
              onPressed: () => unawaited(_confirmAndDeleteChat(convId)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) => MessageList(
                messages: messages,
                chatState: chatState,
                scrollController: _scrollController,
              ),
            ),
          ),
          if (!modelReady)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                gemmaState is GemmaSetupError
                    ? 'AI unavailable: ${gemmaState.message}'
                    : 'AI is loading…',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ChatInputRow(
            controller: _textController,
            onSend: _send,
            enabled: modelReady && !chatState.isGenerating,
          ),
        ],
      ),
    );
  }
}
