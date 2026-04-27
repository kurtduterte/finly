import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/screens/login_screen.dart';
import 'package:finly/features/home/presentation/screens/main_shell.dart';
import 'package:finly/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const ProviderScope(child: FinlyApp()));
}

class FinlyApp extends StatelessWidget {
  const FinlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _AppRouter(),
    );
  }
}

class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) => user == null ? const LoginScreen() : const MainShell(),
    );
  }
}
