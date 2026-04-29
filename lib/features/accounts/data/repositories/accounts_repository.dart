import 'package:finly/core/db/app_database.dart';

class AccountsRepository {
  const AccountsRepository({required this.db});
  final AppDatabase db;

  Stream<List<Account>> watchAll() => db.accountsDao.watchAll();

  Future<List<Account>> getAll() => db.accountsDao.getAll();

  Future<bool> updateAccount(Account account) =>
      db.accountsDao.updateAccount(account);
}
