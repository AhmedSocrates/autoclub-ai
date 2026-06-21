// lib/features/notifications/data/notification_repository.dart
import 'package:auto_club_ai/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  /// Streams notifications for [userId], newest first.
  Stream<List<NotificationModel>> streamForUser(String userId) {
    return _collection
        .where('recipient_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromJson(d.data(), d.id)).toList());
  }

  /// Writes one notification document per recipient in [recipientIds]
  /// and queues a push notification for each.
  Future<void> notifyUsers({
    required List<String> recipientIds,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) async {
    if (recipientIds.isEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();
    for (final recipientId in recipientIds) {
      final ref = _collection.doc();
      final notification = NotificationModel(
        id: ref.id,
        title: title,
        message: message,
        timestamp: now,
        type: type,
        relatedId: relatedId,
        recipientId: recipientId,
      );
      batch.set(ref, notification.toJson());
    }
    await batch.commit();

    await NotificationService.instance.sendPushToUsers(
      recipientIds: recipientIds,
      title: title,
      body: message,
      data: {
        'type': type.name,
        // ignore: use_null_aware_elements
        if (relatedId != null) 'related_id': relatedId,
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _collection.doc(id).update({'is_read': true});
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
