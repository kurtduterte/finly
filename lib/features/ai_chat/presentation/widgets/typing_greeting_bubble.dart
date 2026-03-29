import 'dart:async';

import 'package:finly/features/ai_chat/presentation/widgets/chat_bubble.dart';
import 'package:finly/features/ai_chat/presentation/widgets/typing_indicator_bubble.dart';
import 'package:flutter/material.dart';

/// Shows a typing indicator briefly, then reveals the greeting message.
class TypingGreetingBubble extends StatefulWidget {
  const TypingGreetingBubble({required this.animate, super.key});
  final bool animate;

  @override
  State<TypingGreetingBubble> createState() => _TypingGreetingBubbleState();
}

class _TypingGreetingBubbleState extends State<TypingGreetingBubble> {
  static const _greeting = 'Hi! How can I help you with your Finances?';

  Timer? _revealTimer;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _showText = true;
      return;
    }
    _revealTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showText) return const ChatBubble(text: _greeting, isUser: false);
    return const TypingIndicatorBubble();
  }
}
