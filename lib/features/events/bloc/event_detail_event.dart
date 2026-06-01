import 'package:equatable/equatable.dart';

abstract class EventDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEventDetail extends EventDetailEvent {
  final String eventId;
  LoadEventDetail(this.eventId);
  @override
  List<Object?> get props => [eventId];
}
