import 'package:equatable/equatable.dart';

class EventWithTaskCount extends Equatable {
  final String eventId;
  final String name;
  final String description;
  final DateTime date;
  final int taskCount;

  const EventWithTaskCount({
    required this.eventId,
    required this.name,
    required this.description,
    required this.date,
    required this.taskCount,
  });

  @override
  List<Object?> get props => [eventId, name, description, date, taskCount];
}
