import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get balanceCentavos => integer().withDefault(const Constant(0))();
  TextColumn get color => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
