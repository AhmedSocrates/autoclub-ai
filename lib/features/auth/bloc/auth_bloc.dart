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
      _authSubscription = authRepository.userStream.listen((user) {
        add(AuthUserChanged(user));
      });
    });

    
    on<AuthUserChanged>((event, emit) async {
      if (event.firebaseUser == null) {
        emit(Unauthenticated());
      } else {
        emit(AuthLoading());
        try {
          final userProfile = await userRepository.getUserData(event.firebaseUser!.uid);

          if (userProfile != null) {
            // User is logged in → require 2FA before granting full access
            emit(AwaitingTwoFactor(userProfile));
          } else {
            emit(AuthError("User profile data not found in database."));
          }
        } catch (e) {
          emit(AuthError("Failed to fetch user data."));
        }
      }
    });

    on<TwoFactorVerified>((event, emit) {
      emit(Authenticated(event.user));
    });

    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel(); // Always clean up your streams!
    return super.close();
  }
}