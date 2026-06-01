import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/models/task.dart';
import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {
  final String userId;
  LoadEvents(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddEventSubmit extends EventEvent {
  final EventModel event;
  final List<TaskModel> tasks;
  AddEventSubmit({required this.event, required this.tasks});
  @override
  List<Object?> get props => [event, tasks];
}

class DismissEventAlert extends EventEvent {}
