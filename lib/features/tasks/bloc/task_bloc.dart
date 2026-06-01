import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_event.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_state.dart';
import 'package:auto_club_ai/features/tasks/repositories/task_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  List<TaskModel> _cachedTasks = [];

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadUserTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await taskRepository.getUserTasks(event.userId);
        _cachedTasks = tasks;
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<CompleteTask>((event, emit) async {
      try {
        await taskRepository.completeTask(event.taskId, event.eventId, event.completionMessage);
        emit(TaskAlert('Task marked as completed.'));
      } catch (e) {
        emit(TaskAlert(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<DismissTaskAlert>((event, emit) {
      emit(TaskLoaded(_cachedTasks));
    });
  }
}
