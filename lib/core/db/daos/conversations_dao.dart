import 'package:drift/drift.dart';
import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/tables/chat_messages_table.dart';
import 'package:finly/core/db/tables/conversations_table.dart';

part 'conversations_dao.g.dart';

@DriftAccessor(tables: [Conversations, ChatMessages])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.attachedDatabase);

  Stream<List<Conversation>> watchAll() {
    return (select(conversations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertConversation() =>
      into(conversations).insert(const ConversationsCompanion());

  Future<void> updateTitle(int id, String title) async {
    await (update(conversations)..where((t) => t.id.equals(id))).write(
      ConversationsCompanion(title: Value(title)),
    );
  }

  Future<void> deleteConversation(int id) async {
    await (delete(chatMessages)
          ..where((t) => t.conversationId.equals(id)))
        .go();
    await (delete(conversations)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ChatMessage>> watchMessages(int conversationId) {
    return (select(chatMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<int> insertMessage({
    required int conversationId,
    required String messageText,
    required bool isUser,
  }) =>
      into(chatMessages).insert(
        ChatMessagesCompanion(
          conversationId: Value(conversationId),
          messageText: Value(messageText),
          isUser: Value(isUser ? 1 : 0),
        ),
      );
}
