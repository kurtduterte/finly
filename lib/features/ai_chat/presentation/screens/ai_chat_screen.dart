import 'dart:async';

import 'package:finly/core/db/app_database.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_notifier.dart';
import 'package:finly/features/ai_chat/presentation/providers/chat_providers.dart';
import 'package:finly/features/model_setup/presentation/providers/gemma_setup_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({this.conversationId, super.key});
  final int? conversationId;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(
        () => ref
            .read(chatNotifierProvider.notifier)
            .setConversation(widget.conversationId),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _deleteChat(int convId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text(
          'This will permanently delete the conversation '
          'and all its messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(chatRepositoryProvider).deleteConversation(convId);
    ref.read(chatNotifierProvider.notifier).setConversation(null);
    if (mounted) Navigator.pop(context);
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    unawaited(ref.read(chatNotifierProvider.notifier).sendMessage(text));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final gemmaState = ref.watch(gemmaSetupProvider);
    final convId = chatState.conversationId;

    ref.listen<ChatState>(chatNotifierProvider, (_, _) => _scrollToBottom());

    final messagesAsync = convId != null
        ? ref.watch(conversationMessagesProvider(convId))
        : const AsyncData<List<ChatMessage>>([]);

    final modelReady = gemmaState is GemmaSetupReady;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mich'),
        actions: [
          if (convId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete chat',
              onPressed: () => unawaited(_deleteChat(convId)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                final itemCount =
                    messages.length + (chatState.isGenerating ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: 1 + itemCount,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _TypingGreetingBubble(animate: convId == null);
                    }
                    final msgIndex = i - 1;
                    if (msgIndex < messages.length) {
                      final msg = messages[msgIndex];
                      return _ChatBubble(
                        text: msg.messageText,
                        isUser: msg.isUser == 1,
                      );
                    }
                    return const _TypingIndicatorBubble();
                  },
                );
              },
            ),
          ),
          if (!modelReady)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                gemmaState is GemmaSetupError
                    ? 'AI unavailable: ${gemmaState.message}'
                    : 'AI is loading…',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          _InputRow(
            controller: _textController,
            onSend: _send,
            enabled: modelReady && !chatState.isGenerating,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text.isEmpty ? '…' : text,
          style: TextStyle(
            color: isUser ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Bouncing three-dot typing indicator bubble (reusable).
class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
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

class _TypingGreetingBubble extends StatefulWidget {
  const _TypingGreetingBubble({required this.animate});
  final bool animate;

  @override
  State<_TypingGreetingBubble> createState() => _TypingGreetingBubbleState();
}

class _TypingGreetingBubbleState extends State<_TypingGreetingBubble> {
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
    if (_showText) return const _ChatBubble(text: _greeting, isUser: false);
    return const _TypingIndicatorBubble();
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: const InputDecoration(
                  hintText: 'Ask something…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
