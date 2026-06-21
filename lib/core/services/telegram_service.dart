// lib/core/services/telegram_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thin wrapper around the Telegram Bot API `sendMessage` endpoint.
///
/// The bot token lives in `.env` (same client-side trust model already
/// accepted for `GEMINI_API_KEY` in this project) rather than behind a
/// server, since there is no backend in this sprint.
class TelegramService {
  final String botToken;

  TelegramService(this.botToken);

  /// Sends [text] to [chatId]. Throws on any non-2xx response or network
  /// error so callers can mark the post as failed.
  Future<void> sendMessage({required String chatId, required String text}) async {
    if (botToken.isEmpty) {
      throw Exception('Telegram bot token is not configured.');
    }
    if (chatId.isEmpty) {
      throw Exception('Telegram chat id is not configured.');
    }

    final uri = Uri.https('api.telegram.org', '/bot$botToken/sendMessage');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'text': text,
        'parse_mode': 'Markdown',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Telegram send failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['ok'] != true) {
      throw Exception('Telegram send failed: ${decoded['description'] ?? 'unknown error'}');
    }
  }
}
