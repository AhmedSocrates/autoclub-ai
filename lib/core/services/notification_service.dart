import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  GoRouter? _router;
  RemoteMessage? _pendingMessage;

  void setRouter(GoRouter router) {
    _router = router;
    if (_pendingMessage != null) {
      _navigateFromMessage(_pendingMessage!);
      _pendingMessage = null;
    }
  }

  Future<void> initialize() async {
    await _requestPermission();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    await _saveTokenToFirestore();
    _messaging.onTokenRefresh.listen(_updateTokenInFirestore);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {}

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (_router == null) {
      _pendingMessage = message;
      return;
    }
    _navigateFromMessage(message);
  }

  void _navigateFromMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final relatedId = data['related_id'] as String?;

    if (relatedId == null || relatedId.isEmpty) return;

    if (type == 'assignment' || type == 'taskUpdate') {
      _router?.go('/task/$relatedId');
    } else if (type == 'eventUpdate') {
      _router?.go('/events/event/$relatedId');
    }
  }

  Future<void> _saveTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'fcm_token': token},
      SetOptions(merge: true),
    );
  }

  Future<void> _updateTokenInFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'fcm_token': token},
      SetOptions(merge: true),
    );
  }

  Future<void> updateTokenOnLogin() async {
    await _saveTokenToFirestore();
  }

  Future<void> clearTokenOnLogout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
      {'fcm_token': FieldValue.delete()},
    );
  }

  /// Queues a push notification for each [recipientIds] by writing to the
  /// `push_queue` Firestore collection. A Cloud Function watches this
  /// collection and delivers the actual FCM message to each device.
  Future<void> sendPushToUsers({
    required List<String> recipientIds,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (recipientIds.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('push_queue');

    for (final userId in recipientIds) {
      final ref = collection.doc();
      batch.set(ref, {
        'to_user': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'created_at': FieldValue.serverTimestamp(),
        'sent': false,
      });
    }

    await batch.commit();
  }
}
