//-----------  lib/ai/twilight_alley_AI.dart  -----------
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

/// Handles all OpenAI calls for Twilight Alley so UI code stays clean.
class TwilightAlleyAI {
  static const String _model = 'gpt-3.5-turbo';
  final String _apiKey;

  TwilightAlleyAI._(this._apiKey);

  /// Factory that loads the key from assets/secrets.txt (git‐ignored).
  static Future<TwilightAlleyAI> create() async {
    final key = (await rootBundle.loadString('assets/secrets.txt')).trim();
    return TwilightAlleyAI._(key);
  }

  /// Returns ≤ 4‑sentence coaching/advice based on the user answer & prompt.
  Future<String> getAdvice({required String prompt, required String user}) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    final body = jsonEncode({
      'model': _model,
      'temperature': 0.7,
      'max_tokens': 120,
      'messages': [
        {
          'role': 'system',
          'content':
          'You are a warm mindfulness coach. Reply with concise, actionable advice in **4 sentences or fewer**.'
        },
        {'role': 'user', 'content': 'Prompt: $prompt\nUser: $user'},
      ],
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode != 200) {
      throw Exception('OpenAI error: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['choices'][0]['message']['content'] as String).trim();
  }

  /// Returns a recommendation plus a 1-10 wellness score from GPT.
  Future<(String recommendation, int score)> getSessionSummary({
    required String combinedLog,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    final body = jsonEncode({
      'model': _model,
      'temperature': 0.6,
      'max_tokens': 120,
      'messages': [
        {
          'role': 'system',
          'content': 'When given the full journal, reply in two lines:\n'
              'Recommendation: <short next step>\n'
              'Score: <integer 1-10>',
        },
        {'role': 'user', 'content': combinedLog},
      ],
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode != 200) {
      throw Exception('OpenAI error: ${res.statusCode} ${res.body}');
    }

    final text =
    (jsonDecode(res.body)['choices'][0]['message']['content'] as String)
        .trim();

    final rec = RegExp(r'Recommendation:\s*(.*)', caseSensitive: false)
        .firstMatch(text)
        ?.group(1)
        ?.trim() ?? '';

    final sc  = int.tryParse(
        RegExp(r'Score:\s*(\d+)').firstMatch(text)?.group(1) ?? '5') ?? 5;

    return (rec, sc.clamp(1, 10));
  }

}

