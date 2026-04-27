import 'package:finly/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:finly/features/auth/data/models/auth_user.dart';

class AuthRepository {
  const AuthRepository(this._datasource);

  final FirebaseAuthDatasource _datasource;

  Stream<AuthUser?> get authStateChanges => _datasource.authStateChanges;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.signInWithEmail(email: email, password: password);

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.signUpWithEmail(email: email, password: password);

  Future<AuthUser> signInWithGoogle() => _datasource.signInWithGoogle();

  Future<void> signOut() => _datasource.signOut();

  Future<void> updateDisplayName(String name) =>
      _datasource.updateDisplayName(name);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _datasource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  bool get isEmailUser => _datasource.isEmailUser;
}
