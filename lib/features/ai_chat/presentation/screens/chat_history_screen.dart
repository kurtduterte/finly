import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:finly/features/ai_chat/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConvs = ref.watch(allConversationsProvider);

    void openChat(int? conversationId) {
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

    void showRenameDialog(Conversation conv) {
      final controller = TextEditingController(text: conv.title);
      unawaited(
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Rename Chat'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              onSubmitted: (_) {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  unawaited(
                    ref
                        .read(chatNotifierProvider.notifier)
                        .renameConversation(conv.id, title),
                  );
                }
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final title = controller.text.trim();
                  if (title.isNotEmpty) {
                    unawaited(
                      ref
                          .read(chatNotifierProvider.notifier)
                          .renameConversation(conv.id, title),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ).then((_) => controller.dispose()),
      );
    }

    void showConversationOptions(Conversation conv) {
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.pop(context);
                    showRenameDialog(conv);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    unawaited(
                      ref
                          .read(chatNotifierProvider.notifier)
                          .deleteConversation(conv.id),
                    );
                  },
                ),
              ],
            ),
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
            return const Center(
              child: Text(
                'No chats yet.\nTap + to start.',
                textAlign: TextAlign.center,
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
                onLongPress: () => showConversationOptions(conv),
                onDismissed: () => unawaited(
                  ref
                      .read(chatNotifierProvider.notifier)
                      .deleteConversation(conv.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Chat',
        onPressed: () => openChat(null),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
