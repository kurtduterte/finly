import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        switch (error) {
          final FirebaseAuthException e => e.message ?? e.code,
          _ => error.toString(),
        },
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
