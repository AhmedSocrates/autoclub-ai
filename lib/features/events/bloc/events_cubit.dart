import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/event_repository.dart';
import '../models/leader_event.dart';

class EventsCubit extends Cubit<List<LeaderEvent>> {
  final EventRepository repository;
  final String leaderId;
  StreamSubscription<List<LeaderEvent>>? _sub;

  EventsCubit({required this.repository, required this.leaderId})
      : super(const []) {
    _sub = repository.streamLeaderEvents(leaderId).listen(
          (events) => emit(events),
          onError: (_) => emit(const []),
        );
  }

  Future<void> addEvent(LeaderEvent event) async {
    await repository.createEvent(event, leaderId);
    // Stream listener updates state automatically
  }

  Future<void> deleteEvent(String eventId) async {
    await repository.deleteEvent(eventId);
  }

  Future<void> updateEvent(LeaderEvent event) async {
    await repository.updateEvent(event);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
