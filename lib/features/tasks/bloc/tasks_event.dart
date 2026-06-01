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
  MarkTaskCompleteEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}
