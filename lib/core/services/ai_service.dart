// lib/core/services/ai_service.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart';
import '../../features/social/models/scheduled_post.dart';

class AIService {
  final GenerativeModel _model;
  final GenerativeModel _socialModel;

  AIService(String apiKey)
      : _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey),
        _socialModel = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  /// Generates 3–5 tasks for the given event.
  ///
  /// When [eventDate] is supplied the deadlines are spread evenly across the
  /// window from today to the day before the event, so that `isDueSoon` /
  /// `isDueToday` / `isOverdue` flags on [TaskModel] evaluate correctly in
  /// the UI as time passes.
  Future<List<TaskModel>> generateTasks({
    required String eventName,
    required String eventDescription,
    DateTime? eventDate,
  }) async {
    final prompt = '''
      You are an AI assistant for a University Club.
      The club is organizing an event called: "$eventName".
      Event Details: "$eventDescription".

      Generate 3 to 5 actionable tasks for this event.
      Return ONLY a valid JSON array of objects. Do not use markdown like ```json.

      Each object must have exactly these keys:
      - "name": A short task title (e.g. "Book Venue").
      - "description": Instructions on what to do.
      - "type": Choose one: "Logistics", "Marketing", "Technical", or "General".
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final String? text = response.text;

      if (text == null || text.isEmpty) return [];

      final cleanJson =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonList = jsonDecode(cleanJson);

      final total = jsonList.length;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Calculate the available window (in whole days) before the event.
      // If no event date was given, default to a 14-day window so tasks are
      // spread out rather than all landing on the same day.
      final int windowDays = eventDate != null
          ? eventDate.difference(today).inDays.clamp(total, 365)
          : 14;

      // Space tasks evenly across the window.  Task i gets a deadline at
      // round((i+1) / total * windowDays) days from today, clamped so no
      // deadline falls on or after the event itself.
      DateTime deadlineFor(int index) {
        final fraction = (index + 1) / total;
        final days = (fraction * windowDays).round().clamp(1, windowDays);
        final candidate = today.add(Duration(days: days));
        // Never push a deadline past the event date.
        if (eventDate != null && candidate.isAfter(eventDate)) {
          return eventDate.subtract(const Duration(days: 1));
        }
        return candidate;
      }

      return jsonList.asMap().entries.map((entry) {
        final job = entry.value as Map<String, dynamic>;
        return TaskModel(
          taskId: '',
          eventId: '',
          name: job['name']?.toString() ?? 'Generated Task',
          description: job['description']?.toString() ?? '',
          type: job['type']?.toString() ?? 'General',
          deadline: deadlineFor(entry.key),
          status: false,
          assignedTo: '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to generate tasks: $e');
    }
  }

  /// Generates social copy for an event announcement: an engaging Facebook
  /// caption, a short Telegram message, and an image-generation prompt for
  /// a flyer background.
  Future<SocialPostDraft> generateSocialPost(
    String eventName,
    String eventDescription,
  ) async {
    final prompt = '''
      You are a social media copywriter for a University Car Club.
      The club is announcing an event called: "$eventName".
      Event Details: "$eventDescription".

      Return ONLY a valid JSON object. Do not use markdown like ```json.

      The object must have exactly these keys:
      - "facebook_caption": An engaging, emoji-rich, long-form Facebook post (3-5 sentences) announcing the event.
      - "telegram_message": A short, punchy message using Telegram markdown (*bold*, _italic_) under 280 characters.
      - "poster_prompt": A descriptive image-generation prompt for a digital event flyer background, focused on visual style, mood, and setting.
    ''';

    try {
      final response = await _socialModel.generateContent([Content.text(prompt)]);
      final String? text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI.');
      }

      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      return SocialPostDraft(
        facebookCaption: json['facebook_caption']?.toString() ?? '',
        telegramMessage: json['telegram_message']?.toString() ?? '',
        posterPrompt: json['poster_prompt']?.toString() ?? '',
      );
    } catch (e) {
      throw Exception('Failed to generate social post: $e');
    }
  }
}
