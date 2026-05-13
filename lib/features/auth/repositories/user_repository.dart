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
}