import 'package:finly/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:finly/features/auth/data/models/auth_user.dart';
import 'package:finly/features/auth/data/repositories/auth_repository.dart';
import 'package:finly/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _authDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (_) => FirebaseAuthDatasource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(_authDatasourceProvider)),
);

final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
