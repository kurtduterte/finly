import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/data/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ChatRepository(db.conversationsDao);
});

final allConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  return ref.watch(chatRepositoryProvider).watchConversations();
});

final conversationMessagesProvider =
    StreamProvider.family<List<ChatMessage>, int>((ref, id) {
  return ref.watch(chatRepositoryProvider).watchMessages(id);
});
