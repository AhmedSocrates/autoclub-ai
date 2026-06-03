import 'package:equatable/equatable.dart';
import '../../../core/models/task.dart';

abstract class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskModel> tasks;
  TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Transient state — emitted after a successful mark-complete action.
class TaskCompleteSuccess extends TasksState {
  final List<TaskModel> tasks;
  TaskCompleteSuccess(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
