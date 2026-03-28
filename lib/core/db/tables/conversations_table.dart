import 'package:drift/drift.dart';

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('New Chat'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
