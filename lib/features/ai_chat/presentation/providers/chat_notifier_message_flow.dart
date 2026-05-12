part of 'chat_notifier.dart';

mixin _ChatNotifierMessageFlow on Notifier<ChatState> {
  Future<String> _handleAddExpense(
    String userMessage,
    int convId, {
    String? contextMessage,
  });

  Future<String> _streamConversation(
    String userMessage,
    List<ChatMessage> history,
    int convId,
  );

  String? _latestUserMessage(List<ChatMessage> history);

  Future<_MessageContext> _prepareMessageContext(String text) async {
    final repo = ref.read(chatRepositoryProvider);
    var conversationId = state.conversationId;
    final history = conversationId != null
        ? await repo.getMessages(conversationId)
        : <ChatMessage>[];

    if (conversationId == null) {
      conversationId = await repo.createConversation();
      final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
      unawaited(repo.updateTitle(conversationId, title));
      state = state.copyWith(conversationId: conversationId);
    }

    return _MessageContext(
      repository: repo,
      conversationId: conversationId,
      history: history,
    );
  }

  Future<void> _sendUserMessage(_MessageContext context, String text) async {
    await context.repository.addMessage(
      conversationId: context.conversationId,
      text: text,
      isUser: true,
    );
    state = state.copyWith(isGenerating: true, streamingBuffer: '');
  }

  Future<void> _receiveMessage(
    _MessageContext context,
    String userMessage,
  ) async {
    final conversationId = context.conversationId;

    try {
      final aiText = await _generateAssistantMessage(context, userMessage);
      if (aiText.isEmpty || !_isConversationActive(conversationId)) return;
      await context.repository.addMessage(
        conversationId: conversationId,
        text: aiText,
        isUser: false,
      );
    } on Exception catch (e) {
      if (!_isConversationActive(conversationId)) return;
      await context.repository.addMessage(
        conversationId: conversationId,
        text: 'Sorry, something went wrong: $e',
        isUser: false,
      );
    } finally {
      if (_isConversationActive(conversationId)) {
        state = state.copyWith(isGenerating: false, streamingBuffer: '');
      }
    }
  }

  Future<String> _generateAssistantMessage(
    _MessageContext context,
    String userMessage,
  ) async {
    if (isAddExpenseIntent(userMessage)) {
      return _handleAddExpense(
        userMessage,
        context.conversationId,
        contextMessage: _latestUserMessage(context.history),
      );
    }

    return _streamConversation(
      userMessage,
      context.history,
      context.conversationId,
    );
  }

  bool _isConversationActive(int conversationId) {
    return state.conversationId == conversationId;
  }
}

class _MessageContext {
  const _MessageContext({
    required this.repository,
    required this.conversationId,
    required this.history,
  });

  final ChatRepository repository;
  final int conversationId;
  final List<ChatMessage> history;
}
