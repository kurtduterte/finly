import 'dart:async';

import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('AI Chats')),
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
              final d = conv.createdAt.toLocal();
              final dateStr =
                  '${d.year}-${d.month.toString().padLeft(2, '0')}'
                  '-${d.day.toString().padLeft(2, '0')}';
              return Dismissible(
                key: ValueKey(conv.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Theme.of(context).colorScheme.error,
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                onDismissed: (_) => unawaited(
                  ref
                      .read(chatRepositoryProvider)
                      .deleteConversation(conv.id),
                ),
                child: ListTile(
                  title: Text(conv.title),
                  subtitle: Text(dateStr),
                  onTap: () => openChat(conv.id),
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
