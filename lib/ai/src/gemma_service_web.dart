import 'dart:async';
import 'dart:convert';

import 'package:finly/ai/ai_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _kGemmaWebApiUrl = String.fromEnvironment('GEMMA_WEB_API_URL');
const _kGemmaWebApiKey = String.fromEnvironment('GEMMA_WEB_API_KEY');
const _kMissingApiUrlMessage =
    'Missing GEMMA_WEB_API_URL. Set it in .env.json for web builds.';

class GemmaService {
  final http.Client _client = http.Client();

  Future<bool> isModelReady() async => _kGemmaWebApiUrl.isNotEmpty;

  Future<String> get modelPath async => _kGemmaWebApiUrl;

  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {
    _apiUrlOrThrow();
    onProgress?.call(1);
  }

  Future<String?> generateResponse(String prompt) {
    return _requestCompletion(messages: [AiMessage(text: prompt)]);
  }

  Stream<String> streamResponse(String prompt) {
    return streamMessages([AiMessage(text: prompt)]);
  }

  Stream<String> streamMessages(List<AiMessage> messages) async* {
    final response = await _requestCompletion(messages: messages);
    if (response == null || response.isEmpty) return;
    for (final token in _splitStreamTokens(response)) {
      yield token;
    }
  }

  Future<String?> _requestCompletion({
    required List<AiMessage> messages,
  }) async {
    final uri = _apiUrlOrThrow();
    final payload = _buildPayload(messages);
    final headers = _buildHeaders();
    final response = await _client
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 45));
    if (response.statusCode >= 400) {
      throw Exception(
        'Gemma API error (${response.statusCode}): ${response.body}',
      );
    }
    return _extractText(response.body);
  }

  Uri _apiUrlOrThrow() {
    if (_kGemmaWebApiUrl.isEmpty) {
      throw Exception(_kMissingApiUrlMessage);
    }
    return Uri.parse(_kGemmaWebApiUrl);
  }

  Map<String, Object> _buildPayload(List<AiMessage> messages) {
    return {
      'messages': [
        for (final message in messages)
          {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
      ],
      'stream': false,
    };
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_kGemmaWebApiKey.isNotEmpty)
        'Authorization': 'Bearer $_kGemmaWebApiKey',
    };
  }

  String? _nonEmptyString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _extractMessageText(dynamic message) {
    final directMessage = _nonEmptyString(message);
    if (directMessage != null) return directMessage;
    if (message is! Map<String, dynamic>) return null;
    return _nonEmptyString(message['content']);
  }

  String? _extractChoiceText(dynamic choices) {
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final text = _nonEmptyString(first['text']);
    if (text != null) return text;
    return _extractMessageText(first['message']);
  }

  String? _extractText(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response must be a JSON object.');
      }
      final directText = _nonEmptyString(decoded['text']);
      if (directText != null) return directText;

      final outputText = _nonEmptyString(decoded['output']);
      if (outputText != null) return outputText;

      final messageText = _extractMessageText(decoded['message']);
      if (messageText != null) return messageText;

      final choiceText = _extractChoiceText(decoded['choices']);
      if (choiceText != null) return choiceText;

      throw Exception(
        'Gemma API response missing text/output/message/choices content.',
      );
    } on FormatException {
      if (responseBody.trim().isEmpty) {
        throw Exception('Gemma API returned an empty response.');
      }
      return responseBody.trim();
    }
  }

  Iterable<String> _splitStreamTokens(String text) sync* {
    final matches = RegExp(r'\S+\s*').allMatches(text).toList();
    if (matches.isEmpty) {
      yield text;
      return;
    }
    for (final match in matches) {
      final token = match.group(0);
      if (token != null && token.isNotEmpty) yield token;
    }
  }

  void dispose() {
    _client.close();
  }
}

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  final service = GemmaService();
  ref.onDispose(service.dispose);
  return service;
});
