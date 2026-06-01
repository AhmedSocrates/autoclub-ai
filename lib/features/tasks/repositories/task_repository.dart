import 'package:auto_club_ai/core/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .doc(taskId)
          .update({
            'status': true,
            'completion_message': completionMessage,
          });
    } catch (e) {
      throw Exception('Failed to complete task. Please try again.');
    }
  }

}