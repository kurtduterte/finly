import 'package:finly/features/ai_chat/presentation/screens/chat_history_screen.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({this.displayName, super.key});
  final String? displayName;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    if (displayName == null) return '';
    final name = displayName!.contains('@')
        ? displayName!.split('@').first
        : displayName!.split(' ').first;
    return ', $name';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting$_firstName',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Here's your financial overview",
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ChatHistoryScreen(),
            ),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: cs.inversePrimary, width: 0.5),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: cs.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
