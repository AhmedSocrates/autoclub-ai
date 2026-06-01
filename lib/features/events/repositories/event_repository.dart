import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/features/events/models/event_with_task_count.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events. Please try again.');
    }
  }

  Future<List<EventWithTaskCount>> getEventsWithUserTaskCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .get();

      final events = snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();

      final List<EventWithTaskCount> result = [];
      for (final event in events) {
        final taskSnapshot = await _firestore
            .collection('events')
            .doc(event.eventId)
            .collection('tasks')
            .where('assigned_to', isEqualTo: userId)
            .get();
        result.add(EventWithTaskCount(
          eventId: event.eventId,
          name: event.name,
          description: event.description,
          date: event.date,
          taskCount: taskSnapshot.docs.length,
        ));
      }
      return result;
    } catch (e) {
      throw Exception('Failed to fetch events. Please try again.');
    }
  }

  Future<void> addEvent(EventModel event, List<TaskModel> tasks) async {
    try {
      // Generate the event document reference first to get its ID
      final ref = _firestore.collection('events').doc();
      final eventId = ref.id;

      // Write event with the generated ID
      await ref.set(event.copyWith(eventId: eventId).toJson());

      // Write tasks into the event's subcollection
      if (tasks.isNotEmpty) {
        final batch = _firestore.batch();
        for (final task in tasks) {
          final taskRef = ref.collection('tasks').doc();
          batch.set(taskRef, task.copyWith(taskId: taskRef.id, eventId: eventId).toJson());
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to create event. Please try again.');
    }
  }


  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) throw Exception('Event not found.');
      return EventModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to load event. Please try again.');
    }
  }

  Future<List<TaskModel>> getEventTasks(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .get();

      final List<TaskModel> result = [];
      for (final doc in snapshot.docs) {
        final task = TaskModel.fromJson(doc.data());
        final userDoc = await _firestore
            .collection('users')
            .doc(task.assignedTo)
            .get();
        final userName =
            userDoc.data()?['name'] as String? ?? 'Unknown';
        result.add(task.copyWith(assignedToName: userName));
      }
      return result;
    } catch (e) {
      throw Exception('Failed to load tasks. Please try again.');
    }
  }

  Future<List<Map<String, String>>> getAllMembers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['leader', 'member'])
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'name': (data['name'] as String?) ?? '',
          'role': (data['role'] as String?) ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to retrieve members data.');
    }
  }
}
