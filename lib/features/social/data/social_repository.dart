// lib/features/social/data/social_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheduled_post.dart';

class SocialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('scheduled_posts');

  /// Streams all scheduled posts, soonest first.
  Stream<List<ScheduledPost>> streamScheduledPosts() {
    return _collection.orderBy('scheduled_time').snapshots().map((snap) =>
        snap.docs.map((d) => ScheduledPost.fromJson(d.data(), d.id)).toList());
  }

  /// Creates the post document and returns it with its generated id.
  Future<ScheduledPost> createPost(ScheduledPost post) async {
    final ref = await _collection.add(post.toJson());
    return post.copyWith(id: ref.id);
  }

  Future<void> updateStatus(String id, ScheduledPostStatus status) async {
    await _collection.doc(id).update({'status': status.name});
  }

  Future<void> deletePost(String id) async {
    await _collection.doc(id).delete();
  }
}
