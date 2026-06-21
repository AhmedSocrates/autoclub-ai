import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/features/notifications/data/notification_repository.dart';
import 'package:auto_club_ai/features/notifications/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationRepository _notificationRepository = NotificationRepository();

   /// Streams all tasks assigned to [userId], sorted by deadline ascending.
  Stream<List<TaskModel>> streamMyTasks(String userId) {
    return _firestore
        .collectionGroup('tasks')
        .where('assigned_to', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final tasks =
          snap.docs.map((d) => TaskModel.fromJson(d.data(), d.id)).toList();
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      return tasks;
    });
  }

  /// Streams every task in the club, sorted by deadline ascending (admin view).
  Stream<List<TaskModel>> streamAllTasks() {
    return _firestore
        .collectionGroup('tasks')
        .snapshots()
        .map((snap) {
      final tasks =
          snap.docs.map((d) => TaskModel.fromJson(d.data(), d.id)).toList();
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      return tasks;
    });
  }

  // to get the user (club member) tasks
  Future<List<TaskModel>> getUserTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('tasks')
          .where('assigned_to', isEqualTo: userId)
          .get();

      final List<TaskModel> userTasks = [];

      for (final doc in snapshot.docs) {
        TaskModel task = TaskModel.fromJson(doc.data());

        final eventDoc = await doc.reference.parent.parent?.get();
        final eventName = eventDoc?.data()?['name'] as String? ?? '';

        userTasks.add(task.copyWith(eventName: eventName));
      }

      return userTasks;
    } catch (e) {
      throw Exception('$e');
    }
  }

  // for the member to check the task as completed
  Future<void> completeTask(String taskId, String eventId, String completionMessage) async {
    try {
      final taskRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .doc(taskId);

      final taskDoc = await taskRef.get();
      final taskName = taskDoc.data()?['name'] as String? ?? 'A task';

      await taskRef.update({
        'status': true,
        'completion_message': completionMessage,
      });

      // PB-010: notify the Club President (all leaders) on completion.
      await _notifyLeaders(taskName);
    } catch (e) {
      throw Exception('Failed to complete task. Please try again.');
    }
  }

  Future<void> _notifyLeaders(String taskName) async {
    final leaders = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'leader')
        .get();

    final leaderIds = leaders.docs.map((d) => d.id).toList();
    await _notificationRepository.notifyUsers(
      recipientIds: leaderIds,
      title: 'Task Completed',
      message: '"$taskName" has been marked as complete.',
      type: NotificationType.taskUpdate,
    );
  }
}