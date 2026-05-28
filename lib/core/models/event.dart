import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String eventId;
  final String name;
  final String description;
  final DateTime date;
  final String venue;
  final String? flyer;

  const EventModel({
    required this.eventId,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    this.flyer,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: (json['date'] as Timestamp).toDate(),
      venue: json['venue'] as String,
      flyer: json['flyer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'date': Timestamp.fromDate(date),
      'venue': venue,
      'flyer': flyer,
    };
  }

  @override
  List<Object?> get props => [eventId, date, venue, flyer];
}
