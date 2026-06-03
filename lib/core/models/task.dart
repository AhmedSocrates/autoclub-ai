import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String taskId;
  final String eventId;
  final String name;
  final String description;
  final String type;
  final DateTime deadline;
  final bool status;
  final String completionMessage;
  final String assignedTo;
  final String eventName;
  final String assignedToName;
  final DateTime createdAt;

  // ignore: prefer_const_constructors_in_immutables
  TaskModel({
    required this.taskId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.type,
    required this.deadline,
    this.status = false,
    this.completionMessage = '',
    this.eventName = '',
    this.assignedToName = '',
    required this.assignedTo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? deadline;

  // ── Aliases ─────────────────────────────────────────────────────────────────

  /// Whether the task has been marked done. Alias for [status].
  bool get isCompleted => status;

  /// Display title. Alias for [name].
  String get title => name;

  /// Due date exposed as nullable so UI can guard with `if (task.dueDate != null)`.
  /// Always non-null — the nullable type is a UI-layer contract only.
  DateTime? get dueDate => deadline;

  /// Event context for display. Returns null when [eventName] is empty.
  String? get eventContext => eventName.isNotEmpty ? eventName : null;

  // ── Computed status getters ──────────────────────────────────────────────────

  bool get isOverdue {
    if (isCompleted) return false;
    final today = _today();
    return deadline.isBefore(today);
  }

  bool get isDueToday {
    if (isCompleted) return false;
    final now = DateTime.now();
    return deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
  }

  /// True when the task is due within the next 10 days (exclusive of today and past).
  bool get isDueSoon {
    if (isCompleted || isOverdue || isDueToday) return false;
    return daysUntilDue <= 10;
  }

  /// Calendar days from today until [deadline]. Negative when overdue.
  int get daysUntilDue {
    final dueDay = DateTime(deadline.year, deadline.month, deadline.day);
    return dueDay.difference(_today()).inDays;
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ── Serialisation ────────────────────────────────────────────────────────────

  /// Accepts an optional [docId] so that Firestore repositories that use the
  /// document ID as the primary key can pass it in without a separate lookup.
  factory TaskModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    DateTime? createdAt;
    final raw = json['createdAt'] ?? json['created_at'];
    if (raw is Timestamp) createdAt = raw.toDate();

    return TaskModel(
      taskId: docId ?? (json['task_id'] as String? ?? ''),
      eventId: json['event_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'General',
      deadline: (json['deadline'] as Timestamp).toDate(),
      status: (json['status'] as bool?) ?? false,
      completionMessage: (json['completion_message'] as String?) ?? '',
      assignedTo: json['assigned_to'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  TaskModel copyWith({
    String? taskId,
    String? eventId,
    String? name,
    String? description,
    String? type,
    DateTime? deadline,
    bool? status,
    String? completionMessage,
    String? assignedTo,
    String? eventName,
    String? assignedToName,
    DateTime? createdAt,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      completionMessage: completionMessage ?? this.completionMessage,
      assignedTo: assignedTo ?? this.assignedTo,
      eventName: eventName ?? this.eventName,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'event_id': eventId,
      'name': name,
      'description': description,
      'type': type,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'completion_message': completionMessage,
      'assigned_to': assignedTo,
    };
  }

  @override
  List<Object?> get props => [
        taskId,
        name,
        description,
        type,
        deadline,
        status,
        completionMessage,
        assignedTo,
        eventName,
        assignedToName,
        createdAt,
      ];
}
