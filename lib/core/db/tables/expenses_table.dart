import 'package:drift/drift.dart';
import 'package:finly/core/db/tables/accounts_table.dart';
import 'package:finly/core/db/tables/categories_table.dart';
import 'package:finly/core/db/tables/receipts_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCentavos => integer()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get receiptId =>
      integer().nullable().references(Receipts, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
