import 'package:finly/features/auth/presentation/providers/auth_providers.dart';
import 'package:finly/features/auth/presentation/screens/signup_screen.dart';
import 'package:finly/features/auth/presentation/widgets/app_logo.dart';
import 'package:finly/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:finly/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:finly/features/auth/presentation/widgets/gradient_button.dart';
import 'package:finly/features/auth/presentation/widgets/or_divider.dart';
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
  bool _obscurePassword = true;

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
    final cs = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const AppLogo(),
              const SizedBox(height: 40),
              Text(
                'Welcome back',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue tracking your finances',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (authState.hasError) ...[
                AuthErrorBanner(error: authState.error!),
                const SizedBox(height: 16),
              ],
              AuthTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => isLoading ? null : _signInWithEmail(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Sign In',
                onPressed: isLoading ? null : _signInWithEmail,
                isLoading: isLoading,
              ),
              const SizedBox(height: 14),
              const OrDivider(),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SignupScreen(),
                            ),
                          ),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: cs.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
