import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String taskId;
  final String eventId;
  final String name;
  final String title;
  final String description;
  final String type;
  final DateTime deadline;
  final dynamic status;
  final String completionMessage;
  final String assignedTo;
  final String eventName;
  final String assignedToName;
  final DateTime createdAt;
  final String createdBy;
  final String? eventContext;

  TaskModel._({
    required this.taskId,
    required this.eventId,
    required this.name,
    required this.title,
    required this.description,
    required this.type,
    required this.deadline,
    required this.status,
    required this.completionMessage,
    required this.assignedTo,
    required this.eventName,
    required this.assignedToName,
    required this.createdAt,
    required this.createdBy,
    required this.eventContext,
  });

  factory TaskModel({
    required String taskId,
    String eventId = '',
    String name = '',
    String? title,
    String description = '',
    String type = '',
    DateTime? deadline,
    dynamic status = false,
    String completionMessage = '',
    required String assignedTo,
    String eventName = '',
    String assignedToName = '',
    DateTime? createdAt,
    String createdBy = '',
    String? eventContext,
  }) {
    final fallbackDate = DateTime.now();
    return TaskModel._(
      taskId: taskId,
      eventId: eventId,
      name: name,
      title: title ?? name,
      description: description,
      type: type,
      deadline: deadline ?? createdAt ?? fallbackDate,
      status: status,
      completionMessage: completionMessage,
      assignedTo: assignedTo,
      eventName: eventName,
      assignedToName: assignedToName,
      createdAt: createdAt ?? deadline ?? fallbackDate,
      createdBy: createdBy,
      eventContext: eventContext,
    );
  }

  bool get isCompleted {
    if (status is bool) return status as bool;
    if (status is String) return (status as String).toLowerCase() == 'completed';
    return false;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, [String? id]) {
    final rawDeadline = json['deadline'];
    final rawCreatedAt = json['createdAt'];

    final parsedDeadline = _parseDate(rawDeadline) ?? _parseDate(rawCreatedAt) ?? DateTime.now();
    final parsedCreatedAt = _parseDate(rawCreatedAt) ?? parsedDeadline;

    final computedName = (json['name'] as String?) ?? (json['title'] as String?) ?? '';
    final computedTitle = (json['title'] as String?) ?? computedName;

    return TaskModel(
      taskId: (json['task_id'] as String?) ?? id ?? '',
      eventId: (json['event_id'] as String?) ?? '',
      name: computedName,
      title: computedTitle,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      deadline: parsedDeadline,
      status: json['status'] ?? false,
      completionMessage: json['completion_message'] as String? ?? '',
      assignedTo: (json['assigned_to'] as String?) ?? (json['assignedTo'] as String?) ?? '',
      eventName: json['event_name'] as String? ?? '',
      assignedToName: json['assignedToName'] as String? ?? '',
      createdAt: parsedCreatedAt,
      createdBy: json['createdBy'] as String? ?? '',
      eventContext: json['eventContext'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return usesLegacySchema ? toLegacyJson() : toModernJson();
  }

  bool get usesLegacySchema =>
      eventId.isNotEmpty || name.isNotEmpty || type.isNotEmpty || completionMessage.isNotEmpty;

  Map<String, dynamic> toLegacyJson() {
    return {
      'task_id': taskId,
      'event_id': eventId,
      'name': name,
      'description': description,
      'type': type,
      'deadline': Timestamp.fromDate(deadline),
      'status': isCompleted,
      'completion_message': completionMessage,
      'assigned_to': assignedTo,
    };
  }

  Map<String, dynamic> toModernJson() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'status': isCompleted ? 'completed' : 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      if (eventContext != null) 'eventContext': eventContext,
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? eventId,
    String? eventName,
    String? assignedToName,
    dynamic status,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      name: name,
      title: title,
      description: description,
      type: type,
      deadline: deadline,
      status: status ?? this.status,
      completionMessage: completionMessage,
      assignedTo: assignedTo,
      eventName: eventName ?? this.eventName,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt,
      createdBy: createdBy,
      eventContext: eventContext,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        eventId,
        name,
        title,
        description,
        type,
        deadline,
        status,
        completionMessage,
        assignedTo,
        eventName,
        assignedToName,
        createdAt,
        createdBy,
        eventContext,
      ];

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
