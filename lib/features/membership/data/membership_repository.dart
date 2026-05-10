import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fetch all applications (Stream so the UI updates instantly)
  Stream<List<Map<String, dynamic>>> getPendingApplications() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'pending') // Only get users waiting for approval
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Return the document data along with the unique document ID (uid)
        return {
          'uid': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // 2. Accept Application
  Future<void> approveMember(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'member', // Upgrade their role
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to approve member: $e");
    }
  }

  // 3. Reject Application
  Future<void> rejectMember(String uid) async {
    try {
      // You can either delete the document entirely, or mark them as rejected
      await _firestore.collection('users').doc(uid).update({
        'role': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to reject member: $e");
    }
  }
}