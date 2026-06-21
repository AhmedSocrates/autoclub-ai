import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType {
  taskUpdate,
  assignment,
  eventUpdate,
  system,
}

NotificationType _typeFromString(String? value) {
  return NotificationType.values.firstWhere(
    (t) => t.name == value,
    orElse: () => NotificationType.system,
  );
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? relatedId;
  /// Firestore user id of the intended recipient. Empty for the
  /// hardcoded demo notifications that predate per-user persistence.
  final String recipientId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.relatedId,
    this.recipientId = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return NotificationModel(
      id: docId ?? (json['id'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: _typeFromString(json['type'] as String?),
      isRead: (json['is_read'] as bool?) ?? false,
      relatedId: json['related_id'] as String?,
      recipientId: json['recipient_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'is_read': isRead,
      'related_id': relatedId,
      'recipient_id': recipientId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? relatedId,
    String? recipientId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      recipientId: recipientId ?? this.recipientId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        timestamp,
        type,
        isRead,
        relatedId,
        recipientId,
      ];
}
