import 'package:finly/ai/gemma_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  ChatMessage copyWith({String? text}) =>
      ChatMessage(text: text ?? this.text, isUser: isUser);
}

class ChatState {
  const ChatState({this.messages = const [], this.isGenerating = false});
  final List<ChatMessage> messages;
  final bool isGenerating;

  ChatState copyWith({List<ChatMessage>? messages, bool? isGenerating}) =>
      ChatState(
        messages: messages ?? this.messages,
        isGenerating: isGenerating ?? this.isGenerating,
      );
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  Future<void> sendMessage(String text) async {
    if (state.isGenerating) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: text, isUser: true),
        const ChatMessage(text: '', isUser: false),
      ],
      isGenerating: true,
    );

    try {
      await for (final token
          in ref.read(gemmaServiceProvider).streamResponse(text)) {
        final msgs = List<ChatMessage>.from(state.messages);
        msgs[msgs.length - 1] = msgs.last.copyWith(
          text: msgs.last.text + token,
        );
        state = state.copyWith(messages: msgs);
      }
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
