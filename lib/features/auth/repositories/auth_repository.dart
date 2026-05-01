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
      if (e is FirebaseAuthException) {
      throw Exception(_mapSignUpFirebaseError(e.code));
    }
    throw Exception('Sign up failed. Please try again.');
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
      if (e is FirebaseAuthException) {
      throw Exception(_mapSignInFirebaseError(e.code));
    }
    throw Exception('Sign in failed. Please try again.');
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
      if (e is FirebaseAuthException) {
      throw Exception(_mapEmailSendFirebaseError(e.code));
    }
    throw Exception('Error in sending email verification. Please try again');
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
      if (e is FirebaseAuthException) {
      throw Exception(_mapReloadFirebaseError(e.code));
    }
    throw Exception('Error in fetching user status. Please try again');
    }
  }
}


// to change the error messages to be more suitable and readable
String _mapSignInFirebaseError(String code) {
    switch (code) {
      case 'invalid-credential': return 'Invalid email or password.';
      case 'too-many-requests': return 'Too many attempts. Try again later.';
      default: return 'Sign in failed. Please try again.';
    }
}



String _mapSignUpFirebaseError(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'operation-not-allowed':
      return 'Sign up is currently unavailable. Try again later.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    default:
      return 'Sign up failed. Please try again.';
  }
}

String _mapEmailSendFirebaseError(String code) {
  switch (code) {
     case 'too-many-requests':
      return 'Too many attempts. Please wait before trying again.';
    case 'network-request-failed':
      return 'No internet connection.';
    default:
      return 'Failed to send verification email. Try again.';
  }
}


String _mapReloadFirebaseError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'Your account no longer exists. Please sign up again.';
    case 'user-disabled':
      return 'Your account has been disabled. Please contact support.';
    case 'network-request-failed':
      return 'No internet connection. Please try again.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    default:
      return 'Something went wrong. Please try again.';
  }
}