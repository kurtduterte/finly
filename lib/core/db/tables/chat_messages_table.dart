import 'package:drift/drift.dart';
import 'package:finly/core/db/tables/conversations_table.dart';

// isUser stores 1 for user message, 0 for AI message (BoolColumn hits
// a drift_dev 2.32.x AST parser bug; IntColumn used instead).
// Column named messageText (not text) to avoid shadowing Table.text().
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId =>
      integer().references(Conversations, #id)();
  TextColumn get messageText => text()();
  IntColumn get isUser => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
