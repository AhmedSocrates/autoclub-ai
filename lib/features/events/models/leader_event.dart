import 'package:cloud_firestore/cloud_firestore.dart';

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

  int get assignedCount {
    final set = <String>{};
    for (final task in tasks) {
      if (task.assigneeUserIds.isNotEmpty) {
        for (final id in task.assigneeUserIds) {
          final t = id.trim();
          if (t.isNotEmpty) set.add('id:$t');
        }
      } else {
        for (final name in task.assigneeNames) {
          final t = name.trim();
          if (t.isNotEmpty) set.add('name:$t');
        }
      }
    }
    return set.length;
  }

  factory LeaderEvent.fromJson(Map<String, dynamic> json, String docId) {
    return LeaderEvent(
      id: docId,
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((t) => LeaderEventTask.fromJson(t as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };
}

enum LeaderTaskPriority { low, medium, high }

class LeaderEventTask {
  final String id;
  final String title;
  final LeaderTaskPriority priority;
  final List<String> assigneeUserIds;
  final List<String> assigneeNames;
  final DateTime? dueDate;

  const LeaderEventTask({
    required this.id,
    required this.title,
    required this.priority,
    this.assigneeUserIds = const [],
    this.assigneeNames = const [],
    this.dueDate,
  });

  factory LeaderEventTask.fromJson(Map<String, dynamic> json) {
    return LeaderEventTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      priority: LeaderTaskPriority.values.byName(
          json['priority'] as String? ?? 'medium'),
      assigneeUserIds:
          List<String>.from(json['assigneeUserIds'] as List? ?? []),
      assigneeNames:
          List<String>.from(json['assigneeNames'] as List? ?? []),
      dueDate: json['dueDate'] is Timestamp
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'assigneeUserIds': assigneeUserIds,
        'assigneeNames': assigneeNames,
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      };

  LeaderEventTask copyWith({
    String? id,
    String? title,
    LeaderTaskPriority? priority,
    List<String>? assigneeUserIds,
    List<String>? assigneeNames,
    DateTime? dueDate,
  }) {
    return LeaderEventTask(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assigneeUserIds: assigneeUserIds ?? this.assigneeUserIds,
      assigneeNames: assigneeNames ?? this.assigneeNames,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
