import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listens to settings/recruitment → isOpen field
  Stream<bool> getRegistrationStatus() {
    return _firestore
        .collection('settings')
        .doc('recruitment')
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['isOpen'] as bool? ?? false) : false);
  }

  // Creates/overwrites the application document — UID as doc ID prevents duplicates
  Future<void> submitApplication({
    required String uid,
    required String userName,
    required String committee,
    required String position,
    required String whyPosition,
    required String experience,
  }) async {
    try {
      final batch = _firestore.batch();

      batch.set(_firestore.collection('membership_applications').doc(uid), {
        'uid': uid,
        'userName': userName,
        'committee': committee,
        'position': position,
        'whyPosition': whyPosition,
        'experience': experience,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('users').doc(uid), {
        'role': 'pending',
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Streams from membership_applications collection
  Stream<List<Map<String, dynamic>>> getPendingApplications() {
    return _firestore
        .collection('membership_applications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'uid': doc.id, ...doc.data()})
            .toList());
  }

  // Approve: promote user role + delete application (atomic batch)
  Future<void> approveMember(String uid) async {
    try {
      final batch = _firestore.batch();

      batch.update(_firestore.collection('users').doc(uid), {
        'role': 'member',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      batch.delete(_firestore.collection('membership_applications').doc(uid));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to approve member: $e');
    }
  }

  // Reject: reset user role + delete application (atomic batch)
  Future<void> rejectMember(String uid) async {
    try {
      final batch = _firestore.batch();

      batch.update(_firestore.collection('users').doc(uid), {
        'role': 'student',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      batch.delete(_firestore.collection('membership_applications').doc(uid));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reject member: $e');
    }
  }

  // Admin toggle: opens or closes club registration globally
  Future<void> toggleRegistration(bool isOpen) async {
    try {
      await _firestore
          .collection('settings')
          .doc('recruitment')
          .set({'isOpen': isOpen}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to toggle registration: $e');
    }
  }

  // Streams a single applicant's application document (null = no application)
  Stream<Map<String, dynamic>?> getApplicationStatus(String uid) {
    return _firestore
        .collection('membership_applications')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? {'uid': doc.id, ...doc.data()!} : null);
  }
}
