import 'package:auto_club_ai/core/models/task.dart';
import 'package:equatable/equatable.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  TaskLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskAlert extends TaskState {
  final String message;
  TaskAlert(this.message);
  @override
  List<Object?> get props => [message];
}
