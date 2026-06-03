import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leader_event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Persists a new event to Firestore and returns its generated ID.
  Future<String> createEvent(LeaderEvent event, String leaderId) async {
    try {
      final ref = await _firestore.collection('events').add({
        ...event.toJson(),
        'createdBy': leaderId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Streams all events created by [leaderId], newest first.
  Stream<List<LeaderEvent>> streamLeaderEvents(String leaderId) {
    return _firestore
        .collection('events')
        .where('createdBy', isEqualTo: leaderId)
        .snapshots()
        .map((snap) {
      final events = snap.docs
          .map((d) => LeaderEvent.fromJson(d.data(), d.id))
          .toList();
      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      return events;
    });
  }

  /// Saves updated task list back to an existing event document.
  Future<void> updateEvent(LeaderEvent event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Deletes an event document.
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
