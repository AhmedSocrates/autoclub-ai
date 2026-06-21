import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/features/events/models/event_with_task_count.dart';
import 'package:auto_club_ai/features/notifications/data/notification_repository.dart';
import 'package:auto_club_ai/features/notifications/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationRepository _notificationRepository = NotificationRepository();

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
        final savedTasks = <TaskModel>[];
        for (final task in tasks) {
          final taskRef = ref.collection('tasks').doc();
          final savedTask = task.copyWith(taskId: taskRef.id, eventId: eventId);
          batch.set(taskRef, savedTask.toJson());
          savedTasks.add(savedTask);
        }
        await batch.commit();

        // PB-009: notify whoever a task was assigned to at creation time.
        for (final task in savedTasks.where((t) => t.assignedTo.isNotEmpty)) {
          final dueDate = DateFormat('MMM dd, yyyy').format(task.deadline);
          await _notificationRepository.notifyUsers(
            recipientIds: [task.assignedTo],
            title: 'Task Assigned',
            message: 'You have been assigned to: "${task.name}" for "${event.name}". Due: $dueDate.',
            type: NotificationType.assignment,
            relatedId: task.taskId,
          );
        }
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

  Stream<int> streamEventCount() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snap) => snap.size);
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .get();

      if (tasksSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in tasksSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete the event.');
    }
  }
}
