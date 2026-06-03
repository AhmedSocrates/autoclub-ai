import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart'; // Adjust this import path to match your project

class AIService {
  final GenerativeModel _model;

  // Initialize the Gemini AI model with your API key
  AIService(String apiKey) 
      : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  /// Generates a list of draft tasks based on an event description.
  /// [eventDescription] is what the admin types (e.g., "Host a car show").
  /// [adminUserId] is the ID of the leader generating these tasks.
  Future<List<TaskModel>> generateTasks({
    required String eventDescription,
    required String adminUserId,
  }) async {
    final prompt = '''
      You are a University Club Project Manager. 
      The club is organizing the following event/goal: "$eventDescription".
      Break this down into 5 to 7 actionable, specific tasks.
      
      Return ONLY a valid JSON array of objects. Do not use markdown blocks like ```json.
      Each object must have exactly these two keys:
      - "title": A short, clear task name.
      - "description": Detailed instructions on how to complete the task.
      
      Example format:
      [
        {"title": "Book Venue", "description": "Contact the university admin to secure the parking lot."}
      ]
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final String? text = response.text;

      if (text != null && text.isNotEmpty) {
        // Clean the response in case Gemini adds markdown formatting
        final cleanJsonText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final List<dynamic> jsonList = jsonDecode(cleanJsonText);
        
        // Map the raw JSON directly into your specific TaskModel structure
        return jsonList.map((job) {
          return TaskModel(
            taskId: '', // Firestore will generate the real ID later
            title: job['title']?.toString() ?? 'Generated Task',
            description: job['description']?.toString() ?? 'No description provided.',
            assignedTo: '', // Blank, Admin will assign this later in the UI
            assignedToName: '', // Blank, Admin will assign this later
            status: 'pending',
            createdAt: DateTime.now(),
            createdBy: adminUserId, 
            eventContext: eventDescription, 
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to generate tasks from AI: $e');
    }
  }
}