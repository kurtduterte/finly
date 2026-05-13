import 'package:finly/features/auth/data/models/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

const _kGoogleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

class _SignInCancelledException implements Exception {
  const _SignInCancelledException();

  @override
  String toString() => 'Sign-in cancelled by user.';
}

class _NoUserException implements Exception {
  const _NoUserException();

  @override
  String toString() => 'No authenticated user found.';
}

class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? _buildGoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _buildGoogleSignIn() {
    if (kIsWeb && _kGoogleWebClientId.isNotEmpty) {
      return GoogleSignIn(clientId: _kGoogleWebClientId);
    }
    return GoogleSignIn();
  }

  Stream<AuthUser?> get authStateChanges =>
      _auth.userChanges().map((u) => u == null ? null : _toModel(u));

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toModel(cred.user!);
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final normalizedName = displayName?.trim();
    if (normalizedName != null && normalizedName.isNotEmpty) {
      await user.updateDisplayName(normalizedName);
      await user.reload();
    }
    return _toModel(_auth.currentUser ?? user);
  }

  Future<AuthUser> signInWithGoogle() async {
    if (kIsWeb && _kGoogleWebClientId.isEmpty) {
      throw UnsupportedError(
        'Missing GOOGLE_WEB_CLIENT_ID for web Google sign-in. Set it in '
        '.env.json and run with --dart-define-from-file=.env.json.',
      );
    }
    final account = await _googleSignIn.signIn();
    if (account == null) throw const _SignInCancelledException();

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _toModel(cred.user!);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const _NoUserException();
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  bool get isEmailUser {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  AuthUser _toModel(User user) => AuthUser(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}
