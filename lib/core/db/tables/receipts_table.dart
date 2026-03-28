import 'package:drift/drift.dart';

class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text()();
  TextColumn get aiRawResponse => text().nullable()();
  IntColumn get extractedAmountCentavos => integer().nullable()();
  TextColumn get extractedMerchant => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
