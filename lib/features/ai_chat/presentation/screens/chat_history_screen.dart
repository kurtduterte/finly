import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:finly/features/ai_chat/presentation/widgets/conversation_options_sheet.dart';
import 'package:finly/features/ai_chat/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  void _openChat(int? conversationId) {
    ref.read(chatNotifierProvider.notifier).setConversation(conversationId);
    unawaited(
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AiChatScreen(conversationId: conversationId),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(Conversation conversation) async {
    final controller = TextEditingController(text: conversation.title);
    void save() {
      final title = controller.text.trim();
      if (title.isNotEmpty) {
        unawaited(
          ref
              .read(chatNotifierProvider.notifier)
              .renameConversation(conversation.id, title),
        );
      }
      Navigator.pop(context);
    }

    try {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
            onSubmitted: (_) => save(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _showOptions(Conversation conversation) {
    final notifier = ref.read(chatNotifierProvider.notifier);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => ConversationOptionsSheet(
          onRename: () => unawaited(_showRenameDialog(conversation)),
          onDelete: () =>
              unawaited(notifier.deleteConversation(conversation.id)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No chats yet',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to start a conversation',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final asyncConvs = ref.watch(allConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Finly AI')),
      body: asyncConvs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (convs) {
          if (convs.isEmpty) return _buildEmptyState(cs);
          final notifier = ref.read(chatNotifierProvider.notifier);
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (context, i) {
              final conv = convs[i];
              return ConversationTile(
                conv: conv,
                onTap: () => _openChat(conv.id),
                onLongPress: () => _showOptions(conv),
                onDismissed: () => unawaited(
                  notifier.deleteConversation(conv.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Chat',
        onPressed: () => _openChat(null),
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}
