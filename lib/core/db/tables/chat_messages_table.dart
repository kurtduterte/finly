import 'package:drift/drift.dart';
import 'package:finly/core/db/tables/conversations_table.dart';

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get messageText => text()();
  IntColumn get isUser => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
