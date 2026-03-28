import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/screens/signup_screen.dart';
import 'package:finly/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:finly/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (authState.hasError) ...[
              AuthErrorBanner(error: authState.error!),
              const SizedBox(height: 16),
            ],
            AuthFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AuthFormField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _signInWithEmail,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignupScreen(),
                        ),
                      ),
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
