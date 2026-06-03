import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/leader_event.dart';

class CreateEventState {
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<LeaderEventTask> tasks;

  const CreateEventState({
    this.name = '',
    this.startDate,
    this.endDate,
    this.tasks = const [],
  });

  bool get canSubmit =>
      name.trim().isNotEmpty &&
      startDate != null &&
      endDate != null &&
      !endDate!.isBefore(startDate!);

  CreateEventState copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    List<LeaderEventTask>? tasks,
  }) {
    return CreateEventState(
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tasks: tasks ?? this.tasks,
    );
  }
}

class CreateEventCubit extends Cubit<CreateEventState> {
  CreateEventCubit() : super(const CreateEventState());

  void nameChanged(String value) => emit(state.copyWith(name: value));

  void setStartDate(DateTime date) {
    DateTime end = state.endDate ?? date;
    if (end.isBefore(date)) end = date;
    emit(state.copyWith(startDate: date, endDate: end));
  }

  void setEndDate(DateTime date) {
    DateTime start = state.startDate ?? date;
    if (date.isBefore(start)) start = date;
    emit(state.copyWith(endDate: date, startDate: start));
  }

  void addTask(LeaderEventTask task) =>
      emit(state.copyWith(tasks: [...state.tasks, task]));

  void removeTask(int index) {
    final updated = List<LeaderEventTask>.from(state.tasks)..removeAt(index);
    emit(state.copyWith(tasks: updated));
  }
}
