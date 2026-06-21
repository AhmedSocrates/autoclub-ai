// lib/features/social/models/scheduled_post.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ScheduledPostStatus { pending, posted, failed }

ScheduledPostStatus _statusFromString(String? value) {
  switch (value) {
    case 'posted':
      return ScheduledPostStatus.posted;
    case 'failed':
      return ScheduledPostStatus.failed;
    default:
      return ScheduledPostStatus.pending;
  }
}

class ScheduledPost extends Equatable {
  final String id;
  final String eventId;
  final String eventName;
  final List<String> targetPlatforms;
  final DateTime scheduledTime;
  final ScheduledPostStatus status;
  final String facebookCaption;
  final String telegramMessage;
  final String posterPrompt;
  final DateTime createdAt;

  const ScheduledPost({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.targetPlatforms,
    required this.scheduledTime,
    this.status = ScheduledPostStatus.pending,
    this.facebookCaption = '',
    this.telegramMessage = '',
    this.posterPrompt = '',
    required this.createdAt,
  });

  factory ScheduledPost.fromJson(Map<String, dynamic> json, [String? docId]) {
    return ScheduledPost(
      id: docId ?? (json['id'] as String? ?? ''),
      eventId: json['event_id'] as String? ?? '',
      eventName: json['event_name'] as String? ?? '',
      targetPlatforms: (json['target_platforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      scheduledTime: (json['scheduled_time'] as Timestamp).toDate(),
      status: _statusFromString(json['status'] as String?),
      facebookCaption: json['facebook_caption'] as String? ?? '',
      telegramMessage: json['telegram_message'] as String? ?? '',
      posterPrompt: json['poster_prompt'] as String? ?? '',
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'target_platforms': targetPlatforms,
      'scheduled_time': Timestamp.fromDate(scheduledTime),
      'status': status.name,
      'facebook_caption': facebookCaption,
      'telegram_message': telegramMessage,
      'poster_prompt': posterPrompt,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  ScheduledPost copyWith({
    String? id,
    ScheduledPostStatus? status,
    String? facebookCaption,
    String? telegramMessage,
    String? posterPrompt,
  }) {
    return ScheduledPost(
      id: id ?? this.id,
      eventId: eventId,
      eventName: eventName,
      targetPlatforms: targetPlatforms,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      facebookCaption: facebookCaption ?? this.facebookCaption,
      telegramMessage: telegramMessage ?? this.telegramMessage,
      posterPrompt: posterPrompt ?? this.posterPrompt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        eventName,
        targetPlatforms,
        scheduledTime,
        status,
        facebookCaption,
        telegramMessage,
        posterPrompt,
        createdAt,
      ];
}

/// AI-generated copy for a social post, before it's attached to a
/// [ScheduledPost] and written to Firestore.
class SocialPostDraft extends Equatable {
  final String facebookCaption;
  final String telegramMessage;
  final String posterPrompt;

  const SocialPostDraft({
    required this.facebookCaption,
    required this.telegramMessage,
    required this.posterPrompt,
  });

  @override
  List<Object?> get props => [facebookCaption, telegramMessage, posterPrompt];
}
