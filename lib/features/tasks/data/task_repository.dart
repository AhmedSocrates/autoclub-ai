import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams all tasks assigned to [userId], ordered newest first.
  Stream<List<TaskModel>> streamMyTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromJson(d.data(), d.id)).toList());
  }

  /// Streams every task in the club, ordered newest first (admin view).
  Stream<List<TaskModel>> streamAllTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromJson(d.data(), d.id)).toList());
  }

  /// Marks a single task as completed.
  Future<void> markTaskComplete(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Creates a new task document (called by admin/AI flow).
  Future<void> createTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').add(task.toJson());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }
}
