// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_dao.dart';

// ignore_for_file: type=lint
mixin _$ExpensesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $ReceiptsTable get receipts => attachedDatabase.receipts;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  ExpensesDaoManager get managers => ExpensesDaoManager(this);
}

class ExpensesDaoManager {
  final _$ExpensesDaoMixin _db;
  ExpensesDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db.attachedDatabase, _db.receipts);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
