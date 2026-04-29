import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/accounts/data/repositories/accounts_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(db: ref.watch(appDatabaseProvider));
});

final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAll();
});

final totalBalanceProvider = Provider<int>((ref) {
  return ref.watch(accountsStreamProvider).maybeWhen(
        data: (list) => list.fold(0, (sum, a) => sum + a.balanceCentavos),
        orElse: () => 0,
      );
});
