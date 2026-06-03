import 'package:auto_club_ai/core/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>  doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> createUser(String uid, String username) async {
    try {
      final newUser = UserModel(userId: uid, name: username, role: "student");
      await _firestore.collection("users").doc(newUser.userId).set(newUser.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection("users").doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Emits a new [UserModel] every time the user's Firestore document changes
  /// (e.g. when a leader approves their membership and the role flips to "member").
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Stream<int> streamMemberCount() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['member', 'leader'])
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Streams users that can be assigned tasks (members + leaders).
  Stream<List<UserModel>> streamAssignableUsers() {
    return _firestore
        .collection('users')
        .where('role', whereIn: const ['member', 'leader'])
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((d) => d.data())
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList(growable: false);

      final sorted = [...users]..sort((a, b) => a.name.compareTo(b.name));
      return sorted;
    });
  }
}
