import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo;      // userId
  final String assignedToName;
  final String status;          // 'pending' | 'completed'
  final DateTime createdAt;
  final String createdBy;
  final String? eventContext;

  const TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.eventContext,
  });

  bool get isCompleted => status == 'completed';

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      taskId: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      assignedTo: json['assignedTo'] as String? ?? '',
      assignedToName: json['assignedToName'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: json['createdBy'] as String? ?? '',
      eventContext: json['eventContext'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      if (eventContext != null) 'eventContext': eventContext,
    };
  }

  TaskModel copyWith({String? status}) {
    return TaskModel(
      taskId: taskId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      status: status ?? this.status,
      createdAt: createdAt,
      createdBy: createdBy,
      eventContext: eventContext,
    );
  }

  @override
  List<Object?> get props => [
        taskId, title, description, assignedTo,
        assignedToName, status, createdAt, createdBy, eventContext,
      ];
}
