import 'package:finly/features/auth/data/models/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class _SignInCancelledException implements Exception {
  const _SignInCancelledException();

  @override
  String toString() => 'Sign-in cancelled by user.';
}

class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u == null ? null : _toModel(u));

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
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toModel(cred.user!);
  }

  Future<AuthUser> signInWithGoogle() async {
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

  AuthUser _toModel(User user) => AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
}
