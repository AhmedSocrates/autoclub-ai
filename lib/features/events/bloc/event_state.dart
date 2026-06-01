import 'package:auto_club_ai/features/events/models/event_with_task_count.dart';
import 'package:equatable/equatable.dart';

abstract class EventState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventWithTaskCount> events;
  EventLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class EventError extends EventState {
  final String message;
  EventError(this.message);
  @override
  List<Object?> get props => [message];
}

class EventAlert extends EventState {
  final String message;
  final bool isSuccess;
  EventAlert(this.message, {this.isSuccess = true});
  @override
  List<Object?> get props => [message, isSuccess];
}
