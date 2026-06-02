import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/leader_event.dart';

// ── Edit Task sheet ──────────────────────────────────────────────────────────

class EditTaskState {
  final String title;
  final LeaderTaskPriority priority;
  final Set<String> assigneeUserIds;
  final List<String> assigneeNames;
  final DateTime? dueDate;

  const EditTaskState({
    this.title = '',
    this.priority = LeaderTaskPriority.medium,
    this.assigneeUserIds = const {},
    this.assigneeNames = const [],
    this.dueDate,
  });

  bool get canSave => title.trim().isNotEmpty;

  EditTaskState copyWith({
    String? title,
    LeaderTaskPriority? priority,
    Set<String>? assigneeUserIds,
    List<String>? assigneeNames,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return EditTaskState(
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assigneeUserIds: assigneeUserIds ?? this.assigneeUserIds,
      assigneeNames: assigneeNames ?? this.assigneeNames,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }
}

class EditTaskCubit extends Cubit<EditTaskState> {
  EditTaskCubit({LeaderEventTask? task})
      : super(EditTaskState(
          title: task?.title ?? '',
          priority: task?.priority ?? LeaderTaskPriority.medium,
          assigneeUserIds: {...(task?.assigneeUserIds ?? const [])},
          assigneeNames: [...(task?.assigneeNames ?? const [])],
          dueDate: task?.dueDate,
        ));

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void priorityChanged(LeaderTaskPriority priority) =>
      emit(state.copyWith(priority: priority));

  void setDueDate(DateTime date) => emit(state.copyWith(dueDate: date));

  void clearDueDate() => emit(state.copyWith(clearDueDate: true));

  void setAssignees({required Set<String> ids, required List<String> names}) =>
      emit(state.copyWith(assigneeUserIds: {...ids}, assigneeNames: names));

  void removeAssignee(String userId, Map<String, String> userIdToName) {
    final ids = {...state.assigneeUserIds}..remove(userId);
    final names = ids
        .where(userIdToName.containsKey)
        .map((id) => userIdToName[id]!)
        .toList(growable: false);
    emit(state.copyWith(assigneeUserIds: ids, assigneeNames: names));
  }
}

// ── Assignee picker sheet ────────────────────────────────────────────────────

class AssigneePickerCubit extends Cubit<Set<String>> {
  AssigneePickerCubit(Set<String> initial) : super({...initial});

  void toggle(String userId) {
    final updated = {...state};
    if (updated.contains(userId)) {
      updated.remove(userId);
    } else {
      updated.add(userId);
    }
    emit(updated);
  }

  void clear() => emit({});
}
