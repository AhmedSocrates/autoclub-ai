class LeaderEvent {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<LeaderEventTask> tasks;

  const LeaderEvent({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.tasks,
  });

  /// How many distinct people are assigned across all tasks.
  /// Used for the "assigned" indicator on the Events list.
  int get assignedCount {
    final set = <String>{};
    for (final task in tasks) {
      final hasIds = task.assigneeUserIds.isNotEmpty;
      if (hasIds) {
        for (final id in task.assigneeUserIds) {
          final trimmed = id.trim();
          if (trimmed.isNotEmpty) set.add('id:$trimmed');
        }
      } else {
        for (final name in task.assigneeNames) {
          final trimmed = name.trim();
          if (trimmed.isNotEmpty) set.add('name:$trimmed');
        }
      }
    }
    return set.length;
  }
}

enum LeaderTaskPriority { low, medium, high }

class LeaderEventTask {
  final String id;
  final String title;
  final LeaderTaskPriority priority;
  final List<String> assigneeUserIds;
  final List<String> assigneeNames;

  const LeaderEventTask({
    required this.id,
    required this.title,
    required this.priority,
    this.assigneeUserIds = const [],
    this.assigneeNames = const [],
  });

  LeaderEventTask copyWith({
    String? id,
    String? title,
    LeaderTaskPriority? priority,
    List<String>? assigneeUserIds,
    List<String>? assigneeNames,
  }) {
    return LeaderEventTask(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assigneeUserIds: assigneeUserIds ?? this.assigneeUserIds,
      assigneeNames: assigneeNames ?? this.assigneeNames,
    );
  }
}
