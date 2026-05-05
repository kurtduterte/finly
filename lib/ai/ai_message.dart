class AiMessage {
  const AiMessage({required this.text, this.isUser = true});

  final String text;
  final bool isUser;
}
