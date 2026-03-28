import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:finly/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
              hint: 'Choose a password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _signUp,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
