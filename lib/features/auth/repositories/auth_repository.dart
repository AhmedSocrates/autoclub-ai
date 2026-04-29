import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  Future<User?> signUp({required String email, required String password, required String username}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await sendEmailVerification();

    return credential.user;
  }

  Future<User?> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if(user != null) {
      await user.sendEmailVerification();
    }
  }


  Future<User?> getCurrentUser() async{
    User? user = _firebaseAuth.currentUser;
    if(user != null) {
      await user.reload();
    }
    return _firebaseAuth.currentUser;
  }
}