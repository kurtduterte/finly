import 'package:finly/features/settings/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';

class ChangePasswordFormInputs extends StatelessWidget {
  const ChangePasswordFormInputs({
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.currentObscure,
    required this.newObscure,
    required this.confirmObscure,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    super.key,
  });

  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool currentObscure;
  final bool newObscure;
  final bool confirmObscure;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;

  String? _validateCurrentPassword(String? value) {
    return (value == null || value.isEmpty)
        ? 'Enter your current password'
        : null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a new password';
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    return value != newController.text ? 'Passwords do not match' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordField(
          controller: currentController,
          label: 'Current password',
          obscure: currentObscure,
          onToggle: onToggleCurrent,
          validator: _validateCurrentPassword,
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: newController,
          label: 'New password',
          obscure: newObscure,
          onToggle: onToggleNew,
          validator: _validateNewPassword,
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: confirmController,
          label: 'Confirm new password',
          obscure: confirmObscure,
          onToggle: onToggleConfirm,
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }
}
