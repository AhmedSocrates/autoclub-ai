import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/models/task.dart';
import 'package:equatable/equatable.dart';

abstract class EventDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final EventModel event;
  final List<TaskModel> tasks;
  EventDetailLoaded({required this.event, required this.tasks});
  @override
  List<Object?> get props => [event, tasks];
}

class EventDetailError extends EventDetailState {
  final String message;
  EventDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
