import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get iconCodepoint => integer()();
  TextColumn get color => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}
