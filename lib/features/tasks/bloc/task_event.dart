import 'package:auto_club_ai/core/models/task.dart';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserTasks extends TaskEvent {
  final String userId;
  LoadUserTasks(this.userId);
  @override
  List<Object?> get props => [userId];
}

class CompleteTask extends TaskEvent {
  final String taskId;
  final String eventId;
  final String completionMessage;
  CompleteTask(this.taskId, this.eventId, this.completionMessage);
  @override
  List<Object?> get props => [taskId, eventId, completionMessage];
}

class AddTasks extends TaskEvent {
  final List<TaskModel> tasks;
  final String eventId;
  AddTasks(this.tasks, this.eventId);
  @override
  List<Object?> get props => [tasks, eventId];
}

class DismissTaskAlert extends TaskEvent {}
