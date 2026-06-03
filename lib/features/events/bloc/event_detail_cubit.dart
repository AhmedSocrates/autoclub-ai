import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/task.dart';
import '../../tasks/data/task_repository.dart';
import '../data/event_repository.dart';
import '../models/leader_event.dart';

enum PublishStatus { idle, loading, success, error }

class EventDetailState {
  final LeaderEvent event;
  final PublishStatus publishStatus;
  final int publishedCount;
  final String? publishError;

  const EventDetailState({
    required this.event,
    this.publishStatus = PublishStatus.idle,
    this.publishedCount = 0,
    this.publishError,
  });

  EventDetailState copyWith({
    LeaderEvent? event,
    PublishStatus? publishStatus,
    int? publishedCount,
    String? publishError,
  }) {
    return EventDetailState(
      event: event ?? this.event,
      publishStatus: publishStatus ?? this.publishStatus,
      publishedCount: publishedCount ?? this.publishedCount,
      publishError: publishError,
    );
  }
}

class EventDetailCubit extends Cubit<EventDetailState> {
  final TaskRepository taskRepository;
  final EventRepository eventRepository;

  EventDetailCubit(
    LeaderEvent event, {
    required this.taskRepository,
    required this.eventRepository,
  }) : super(EventDetailState(event: event));

  void clearTasks() {
    final updated = _rebuildEvent(tasks: const []);
    emit(state.copyWith(publishStatus: PublishStatus.idle, event: updated));
    _save(updated);
  }

  void updateTask(LeaderEventTask updated) {
    final newEvent = _rebuildEvent(
      tasks: state.event.tasks
          .map((t) => t.id == updated.id ? updated : t)
          .toList(growable: false),
    );
    emit(state.copyWith(publishStatus: PublishStatus.idle, event: newEvent));
    _save(newEvent);
  }

  void deleteTask(String taskId) {
    final newEvent = _rebuildEvent(
      tasks: state.event.tasks
          .where((t) => t.id != taskId)
          .toList(growable: false),
    );
    emit(state.copyWith(publishStatus: PublishStatus.idle, event: newEvent));
    _save(newEvent);
  }

  Future<void> publishTasks({required String leaderUserId}) async {
    final assignedTasks = state.event.tasks
        .where((t) => t.assigneeUserIds.isNotEmpty)
        .toList();

    if (assignedTasks.isEmpty) {
      emit(state.copyWith(
        publishStatus: PublishStatus.error,
        publishError: 'No tasks have assignees. Assign members first.',
      ));
      return;
    }

    emit(state.copyWith(publishStatus: PublishStatus.loading));

    try {
      int count = 0;
      for (final leaderTask in assignedTasks) {
        for (int i = 0; i < leaderTask.assigneeUserIds.length; i++) {
          final userId = leaderTask.assigneeUserIds[i];
          final name = i < leaderTask.assigneeNames.length
              ? leaderTask.assigneeNames[i]
              : 'Member';

          await taskRepository.createTask(TaskModel(
            taskId: '',
            eventId: state.event.id,
            name: leaderTask.title,
            description: 'Priority: ${leaderTask.priority.name}',
            type: 'General',
            deadline: leaderTask.dueDate ?? state.event.endDate,
            assignedTo: userId,
            assignedToName: name,
            eventName: state.event.name,
            status: false,
            createdAt: DateTime.now(),
          ));
          count++;
        }
      }
      emit(state.copyWith(
        publishStatus: PublishStatus.success,
        publishedCount: count,
      ));
    } catch (e) {
      emit(state.copyWith(
        publishStatus: PublishStatus.error,
        publishError: 'Failed to publish: $e',
      ));
    }
  }

  void resetPublishStatus() =>
      emit(state.copyWith(publishStatus: PublishStatus.idle));

  LeaderEvent _rebuildEvent({required List<LeaderEventTask> tasks}) {
    return LeaderEvent(
      id: state.event.id,
      name: state.event.name,
      startDate: state.event.startDate,
      endDate: state.event.endDate,
      tasks: tasks,
    );
  }

  void _save(LeaderEvent event) {
    // Fire-and-forget — UI doesn't wait for this
    eventRepository.updateEvent(event).catchError((_) {});
  }
}
