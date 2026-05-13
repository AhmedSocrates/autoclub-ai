import 'package:auto_club_ai/core/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> changeUserName(String name, UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.userId).update({
        "name": name,
      });
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e.code));
    } catch (e) {
      throw Exception('Failed to update username. Please try again.');
    }
  }
}

String _mapFirestoreError(String code) {
  switch (code) {
    case 'not-found':
      return 'User profile not found.';
    case 'permission-denied':
      return 'You do not have permission to perform this action.';
    case 'unavailable':
      return 'Service is currently unavailable. Please try again later.';
    case 'deadline-exceeded':
      return 'Request timed out. Please check your connection and try again.';
    case 'network-request-failed':
      return 'No internet connection. Please try again.';
    default:
      return 'Failed to update username. Please try again.';
  }
}