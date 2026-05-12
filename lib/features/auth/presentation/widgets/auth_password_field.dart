import 'package:finly/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    super.key,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AuthTextField(
      controller: controller,
      label: 'Password',
      hint: '••••••••',
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }
}
