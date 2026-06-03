import 'package:auto_club_ai/features/events/bloc/event_detail_event.dart';
import 'package:auto_club_ai/features/events/bloc/event_detail_state.dart';
import 'package:auto_club_ai/features/events/repositories/event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  final EventRepository eventRepository;

  EventDetailBloc({required this.eventRepository}) : super(EventDetailInitial()) {
    on<LoadEventDetail>((event, emit) async {
      emit(EventDetailLoading());
      try {
        final eventModel = await eventRepository.getEventById(event.eventId);
        final tasks = await eventRepository.getEventTasks(event.eventId);
        emit(EventDetailLoaded(event: eventModel, tasks: tasks));
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
      }
    });
  }
}
