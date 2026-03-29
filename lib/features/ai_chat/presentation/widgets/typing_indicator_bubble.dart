import 'dart:async';

import 'package:flutter/material.dart';

/// Bouncing three-dot typing indicator shown while AI is generating.
class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({super.key});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    for (var i = 0; i < _dots.length; i++) {
      unawaited(
        Future.delayed(Duration(milliseconds: i * 160), () {
          if (mounted) unawaited(_dots[i].repeat(reverse: true));
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final d in _dots) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _dots[i],
              builder: (_, _) => Transform.translate(
                offset: Offset(0, -5 * _dots[i].value),
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
