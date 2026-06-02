// lib/core/services/ai_service.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart'; 

class AIService {
  final GenerativeModel _model;

  // Make sure to pass your actual Gemini API Key here
  AIService(String apiKey) 
      : _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  Future<List<TaskModel>> generateTasks({
    required String eventName,
    required String eventDescription,
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

      if (text != null && text.isNotEmpty) {
        final cleanJsonText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> jsonList = jsonDecode(cleanJsonText);
        
        return jsonList.map((job) {
          return TaskModel(
            taskId: '', // Set by DB later
            eventId: '', // Set by DB later
            name: job['name']?.toString() ?? 'Generated Task',
            description: job['description']?.toString() ?? '',
            type: job['type']?.toString() ?? 'General',
            deadline: DateTime.now().add(const Duration(days: 7)), // Default 1 week
            assignedTo: '', // Admin assigns manually in UI
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to generate tasks: $e');
    }
  }
}