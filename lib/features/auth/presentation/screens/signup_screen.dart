import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:finly/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:finly/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:finly/features/auth/presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _displayName() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    return '$first $last'.trim();
  }

  Future<void> _signUp() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter your first and last name.'),
          ),
        );
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayName(),
        );

    final hasError = ref.read(authNotifierProvider).hasError;
    if (!mounted || hasError) return;
    Navigator.of(context).pop('Account created successfully. Please sign in.');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Join Finly',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start tracking your finances today',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              if (authState.hasError) ...[
                AuthErrorBanner(error: authState.error!),
                const SizedBox(height: 16),
              ],
              AuthTextField(
                controller: _firstNameController,
                label: 'First name',
                hint: 'Juan',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _lastNameController,
                label: 'Last name',
                hint: 'Dela Cruz',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AuthPasswordField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onSubmitted: (_) => isLoading ? null : _signUp(),
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 8),
              Text(
                'Use at least 8 characters with a mix of letters and numbers.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : _signUp,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
