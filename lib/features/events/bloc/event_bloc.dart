import 'package:auto_club_ai/features/events/bloc/event_event.dart';
import 'package:auto_club_ai/features/events/bloc/event_state.dart';
import 'package:auto_club_ai/features/events/repositories/event_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository;

  EventBloc({required this.eventRepository}) : super(EventInitial()) {
    on<LoadEvents>((event, emit) async {
      emit(EventLoading());
      try {
        final events = await eventRepository.getEventsWithUserTaskCount(event.userId);
        emit(EventLoaded(events));
      } catch (e) {
        emit(EventError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<AddEventSubmit>((event, emit) async {
      try {
        await eventRepository.addEvent(event.event, event.tasks);
        emit(EventAlert('Event created successfully.'));
      } catch (e) {
        emit(EventAlert(
          e.toString().replaceFirst('Exception: ', ''),
          isSuccess: false,
        ));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(EventLoading());
      try {
        await eventRepository.deleteEvent(event.eventId);
        final events = await eventRepository.getEventsWithUserTaskCount(event.userId);
        emit(EventLoaded(events));
        emit(EventAlert('Event deleted successfully.'));
      } catch (e) {
        emit(EventAlert(
          e.toString().replaceFirst('Exception: ', ''),
          isSuccess: false,
        ));
      }
    });

    on<DismissEventAlert>((event, emit) {
      emit(EventInitial());
    });
  }
}
