import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToName;
  final String status;
  final DateTime createdAt;
  final String createdBy;
  final String? eventContext;
  final DateTime? dueDate;

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
    this.dueDate,
  });

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final today = DateTime.now();
    return dueDate!.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool get isDueToday {
    if (dueDate == null || isCompleted) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year &&
        dueDate!.month == today.month &&
        dueDate!.day == today.day;
  }

  /// Days remaining until due date (0 = today, negative = overdue).
  int get daysUntilDue {
    if (dueDate == null) return 999;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDay =
        DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDay.difference(todayDate).inDays;
  }

  /// True when due within 10 days and not already today/overdue/completed.
  bool get isDueSoon {
    if (dueDate == null || isCompleted || isDueToday || isOverdue) return false;
    return daysUntilDue <= 10;
  }

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
      dueDate: json['dueDate'] is Timestamp
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
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
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
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
      dueDate: dueDate,
    );
  }

  @override
  List<Object?> get props => [
        taskId, title, description, assignedTo,
        assignedToName, status, createdAt, createdBy, eventContext, dueDate,
      ];
}
