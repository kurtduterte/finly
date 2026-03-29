import 'package:finly/core/db/app_database.dart';
import 'package:finly/core/db/daos/conversations_dao.dart';

class ChatRepository {
  const ChatRepository(this._dao);
  final ConversationsDao _dao;

  Stream<List<Conversation>> watchConversations() => _dao.watchAll();

  Future<int> createConversation() => _dao.insertConversation();

  Future<void> updateTitle(int id, String title) =>
      _dao.updateTitle(id, title);

  Future<void> deleteConversation(int id) => _dao.deleteConversation(id);

  Stream<List<ChatMessage>> watchMessages(int conversationId) =>
      _dao.watchMessages(conversationId);

  Future<List<ChatMessage>> getMessages(int conversationId) =>
      _dao.getMessages(conversationId);

  Future<void> addMessage({
    required int conversationId,
    required String text,
    required bool isUser,
  }) async {
    await _dao.insertMessage(
      conversationId: conversationId,
      messageText: text,
      isUser: isUser,
    );
  }
}
