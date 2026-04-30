class ChatState {
  const ChatState({
    this.conversationId,
    this.isGenerating = false,
    this.streamingBuffer = '',
  });
  final int? conversationId;
  final bool isGenerating;
  final String streamingBuffer;

  ChatState copyWith({
    bool clearConversationId = false,
    int? conversationId,
    bool? isGenerating,
    String? streamingBuffer,
  }) {
    return ChatState(
      conversationId: clearConversationId
          ? null
          : conversationId ?? this.conversationId,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingBuffer: streamingBuffer ?? this.streamingBuffer,
    );
  }
}
