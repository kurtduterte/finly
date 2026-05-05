import 'package:finly/core/theme/app_theme.dart';
import 'package:finly/core/theme/theme_provider.dart';
import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/screens/login_screen.dart';
import 'package:finly/features/home/presentation/screens/main_shell.dart';
import 'package:finly/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart'
    if (dart.library.html) 'package:finly/core/stubs/flutter_gemma_stub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FlutterGemma.initialize();
  } on Exception catch (_) {
    // Non-fatal: Gemma may not be supported on this device.
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  } on Exception catch (_) {
    // Firebase failed for an unexpected reason — UI will surface the error
    // via authStateProvider rather than crashing before runApp().
  }
  runApp(const ProviderScope(child: FinlyApp()));
}

class FinlyApp extends ConsumerWidget {
  const FinlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _AppRouter(),
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
