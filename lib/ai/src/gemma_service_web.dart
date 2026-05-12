import 'dart:async';
import 'dart:convert';

import 'package:finly/ai/ai_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _kGemmaWebApiUrl = String.fromEnvironment('GEMMA_WEB_API_URL');
const _kGemmaWebApiKey = String.fromEnvironment('GEMMA_WEB_API_KEY');

class GemmaService {
  final http.Client _client = http.Client();

  Future<bool> isModelReady() async => _kGemmaWebApiUrl.isNotEmpty;

  Future<String> get modelPath async => _kGemmaWebApiUrl;

  Future<void> prepareModel({
    void Function(double progress)? onProgress,
  }) async {
    if (_kGemmaWebApiUrl.isEmpty) {
      throw Exception(
        'Missing GEMMA_WEB_API_URL. Set it in .env.json for web builds.',
      );
    }
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
    if (_kGemmaWebApiUrl.isEmpty) {
      throw Exception(
        'Missing GEMMA_WEB_API_URL. Set it in .env.json for web builds.',
      );
    }
    final uri = Uri.parse(_kGemmaWebApiUrl);
    final payload = {
      'messages': [
        for (final message in messages)
          {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
      ],
      'stream': false,
    };
    final headers = {
      'Content-Type': 'application/json',
      if (_kGemmaWebApiKey.isNotEmpty)
        'Authorization': 'Bearer $_kGemmaWebApiKey',
    };
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

  String? _extractText(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response must be a JSON object.');
      }
      final direct = decoded['text'] as String?;
      if (direct != null && direct.trim().isNotEmpty) return direct.trim();

      final output = decoded['output'] as String?;
      if (output != null && output.trim().isNotEmpty) return output.trim();

      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      if (message is Map<String, dynamic>) {
        final content = message['content'] as String?;
        if (content != null && content.trim().isNotEmpty) return content.trim();
      }

      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        if (first is Map<String, dynamic>) {
          final text = first['text'] as String?;
          if (text != null && text.trim().isNotEmpty) return text.trim();
          final choiceMessage = first['message'];
          if (choiceMessage is Map<String, dynamic>) {
            final content = choiceMessage['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      }
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
