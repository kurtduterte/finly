import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:finly/features/ai_chat/presentation/widgets/conversation_options_sheet.dart';
import 'package:finly/features/ai_chat/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final asyncConvs = ref.watch(allConversationsProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);

    void openChat(int? conversationId) {
      notifier.setConversation(conversationId);
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AiChatScreen(conversationId: conversationId),
          ),
        ),
      );
    }

    void showRenameDialog(Conversation conv) {
      final ctrl = TextEditingController(text: conv.title);
      void save() {
        final title = ctrl.text.trim();
        if (title.isNotEmpty) {
          unawaited(notifier.renameConversation(conv.id, title));
        }
        Navigator.pop(context);
      }

      unawaited(
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Rename Chat'),
            content: TextField(
              controller: ctrl,
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
        ).then((_) => ctrl.dispose()),
      );
    }

    void showOptions(Conversation conv) {
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          builder: (_) => ConversationOptionsSheet(
            onRename: () => showRenameDialog(conv),
            onDelete: () => unawaited(notifier.deleteConversation(conv.id)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finly AI')),
      body: asyncConvs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (convs) {
          if (convs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to start a conversation',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (context, i) {
              final conv = convs[i];
              return ConversationTile(
                conv: conv,
                onTap: () => openChat(conv.id),
                onLongPress: () => showOptions(conv),
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
        onPressed: () => openChat(null),
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}
