import 'package:finly/features/auth/data/repositories/auth_repository.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<void> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }

  @override
  Future<void> build() async {}

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _run(() => _repository.signInWithEmail(email: email, password: password));

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _run(() => _repository.signUpWithEmail(email: email, password: password));

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signOut() => _run(_repository.signOut);

  Future<void> updateDisplayName(String name) =>
      _run(() => _repository.updateDisplayName(name));

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) => _run(
    () => _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
  );
}
