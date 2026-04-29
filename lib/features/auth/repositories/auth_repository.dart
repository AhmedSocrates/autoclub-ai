import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  Future<User?> signUp({required String email, required String password, required String username}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await sendEmailVerification();

      return credential.user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<User?> signIn({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if(user != null) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }


  Future<User?> getCurrentUser() async{
    try {
      User? user = _firebaseAuth.currentUser;
      if(user != null) {
        await user.reload();
      }
      return _firebaseAuth.currentUser;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}