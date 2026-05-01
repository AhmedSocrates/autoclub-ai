import 'dart:async';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:auto_club_ai/features/auth/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  late StreamSubscription<User?> _authSubscription;

  AuthBloc({
    required this.authRepository,
    required this.userRepository,
  }) : super(AuthInitial()) {
    
    on<AppStarted>((event, emit) {
      _authSubscription = authRepository.userStream.listen((user) async {
        if(user != null) {
          try {
            await user.reload();
            add(AuthUserChanged(user));
          } catch(e) {
            await authRepository.signOut();
            add(AuthUserChanged(null));
          }
        } 
        else {
          add(AuthUserChanged(null));
        }
      });
    });

    
    on<AuthUserChanged>((event, emit) async {
      if (event.firebaseUser == null) {
        emit(Unauthenticated());
      } else {
        emit(AuthLoading());
        try {
          if (!event.firebaseUser!.emailVerified) {
            emit(AwaitingEmailVerfication());
            return;
          }

          final userProfile = await userRepository.getUserData(event.firebaseUser!.uid);

          if (userProfile != null) {
            emit(Authenticated(userProfile));
          } else {
            emit(AuthError("User profile data not found in database."));
          }
        } catch (e) {
          emit(AuthError("Failed to fetch user data."));
        }
      }
    });
    
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signIn(email: event.email, password: event.password);
        
      } catch(e) {
        emit(AuthError(e.toString().replaceFirst("Exception: ", "")));
        add(AuthUserChanged(null));
      }
    }); 

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final User? newUser = await authRepository.signUp(email: event.email, password: event.password, username: event.username);
        if(newUser != null) {
          await userRepository.createUser(newUser.uid, event.username); 
        }
      } catch(e) {
        emit(AuthError(e.toString().replaceFirst("Exception: ", "")));
        add(AuthUserChanged(null));
      } 
    });


    on<EmailVerificationCompleted>((event, emit) async {
      emit(AuthLoading());
      try {
        final User? user = await authRepository.getCurrentUser();
        if (user != null && !user.emailVerified) {
          emit(AuthError("Your email has not been verified yet. Please check your inbox."));
          emit(AwaitingEmailVerfication());
        } else {
          add(AuthUserChanged(user));
        }
    } catch(e) {
      emit(AuthError(e.toString().replaceFirst("Exception: ", "")));
    }
    });


    on<EmailVerified>((event, emit) {
      emit(Authenticated(event.user));
    });

    on<EmailVerificationRequested>((event, emit) async{
      try {
        await authRepository.sendEmailVerification();
      } catch (e) {
        emit(AuthError(e.toString().replaceFirst("Exception: ", "")));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(Unauthenticated());
    });

    on<CreateAccount>((event, emit) async{
      emit(AuthCreateAccount());
    }); 
  }

  @override
  Future<void> close() {
    _authSubscription.cancel(); // Always clean up your streams!
    return super.close();
  }
}