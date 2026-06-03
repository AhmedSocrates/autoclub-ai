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

  const TaskModel({
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
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      deadline: (json['deadline'] as Timestamp).toDate(),
      status: (json['status'] as bool?) ?? false,
      completionMessage: (json['completion_message'] as String?) ?? '',
      assignedTo: json['assigned_to'] as String,
    );
  }

  TaskModel copyWith({
    String? taskId,
    String? eventId,
    String? eventName,
    String? assignedToName,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      name: name,
      description: description,
      type: type,
      deadline: deadline,
      status: status,
      completionMessage: completionMessage,
      assignedTo: assignedTo,
      eventName: eventName ?? this.eventName,
      assignedToName: assignedToName ?? this.assignedToName,
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
  List<Object?> get props => [taskId, name, description, type, deadline, status, completionMessage, assignedTo];
}
