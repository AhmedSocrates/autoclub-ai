import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/task_repository.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository repository;

  TasksBloc({required this.repository}) : super(TasksInitial()) {

    on<LoadMyTasksEvent>(
      (event, emit) async {
        emit(TasksLoading());
        try {
          await emit.forEach(
            repository.streamMyTasks(event.userId),
            onData: (tasks) => TasksLoaded(tasks),
            onError: (e, _) => TasksError(e.toString()),
          );
        } catch (e) {
          emit(TasksError(e.toString()));
        }
      },
      transformer: restartable(),
    );

    on<MarkTaskCompleteEvent>((event, emit) async {
      // Optimistically keep the current list visible while we write to Firestore.
      // The stream will push the updated state automatically after the write.
      try {
        await repository.completeTask(event.taskId, event.eventId, event.completionMessage);
      } catch (e) {
        emit(TasksError('Failed to mark task as complete.'));
      }
    });
  }
}
