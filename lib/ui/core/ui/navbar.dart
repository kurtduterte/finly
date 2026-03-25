import 'package:finly/ui/feature/auth/widgets/auth_screen.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Finly'),
      actions: [
        TextButton(
          onPressed: () => _openAuthScreen(context, initialIsLogin: true),
          child: const Text('Login'),
        ),
        TextButton(
          onPressed: () => _openAuthScreen(context, initialIsLogin: false),
          child: const Text('Signup'),
        ),
      ],
    );
  }

  void _openAuthScreen(BuildContext context, {required bool initialIsLogin}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AuthScreen(initialIsLogin: initialIsLogin),
      ),
    );
  }
}
