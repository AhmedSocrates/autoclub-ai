import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams all tasks assigned to [userId], sorted by deadline ascending.
  Stream<List<TaskModel>> streamMyTasks(String userId) {
    return _firestore
        .collection('tasks')
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
        .collection('tasks')
        .snapshots()
        .map((snap) {
      final tasks =
          snap.docs.map((d) => TaskModel.fromJson(d.data(), d.id)).toList();
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      return tasks;
    });
  }

  /// Marks a single task as completed.
  Future<void> markTaskComplete(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': true,
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
