// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_dao.dart';

// ignore_for_file: type=lint
mixin _$ConversationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ChatMessagesTable get chatMessages => attachedDatabase.chatMessages;
  ConversationsDaoManager get managers => ConversationsDaoManager(this);
}

class ConversationsDaoManager {
  final _$ConversationsDaoMixin _db;
  ConversationsDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db.attachedDatabase, _db.chatMessages);
}
