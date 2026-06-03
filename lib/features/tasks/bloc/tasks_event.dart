import 'package:equatable/equatable.dart';

abstract class TasksEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMyTasksEvent extends TasksEvent {
  final String userId;
  LoadMyTasksEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class MarkTaskCompleteEvent extends TasksEvent {
  final String taskId;
  final String eventId;
  final String completionMessage;
  MarkTaskCompleteEvent(this.taskId, this.eventId, this.completionMessage);
  @override
  List<Object?> get props => [taskId, eventId, completionMessage];
}
