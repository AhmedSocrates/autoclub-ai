import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:auto_club_ai/features/settings/bloc/user/user_event.dart';
import 'package:auto_club_ai/features/settings/bloc/user/user_state.dart';
import 'package:auto_club_ai/features/settings/repository/user_profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserProfileRepository userProfileRepository;
  final AuthRepository authRepository;

  UserBloc({
    required this.userProfileRepository,
    required this.authRepository,
  }) : super(UsernameInitial()) {

    on<ChangeUserName>((event, emit) async {
      try {
        emit(UsernameLoading());
        await userProfileRepository.changeUserName(event.name, event.user);
        emit(ShowAlert("Username has been changed to ${event.name}"));
      } catch (e) {
        emit(ShowAlert(e.toString().replaceFirst("Exception: ", "")));
      }
    });

    on<ViewInputField>((event, emit) {
      emit(UsernameChangeInputRequested());
    });

    on<DismissAlert>((event, emit) {
      emit(UsernameInitial());
    });

    on<ChangePasswordRequested>((event, emit) async {
      final email = authRepository.currentUserEmail;
      if (email == null) {
        emit(ShowAlert('Unable to determine your email. Please sign in again.'));
        return;
      }
      try {
        await authRepository.sendResetPasswordEmail(email);
        emit(ShowAlert('Password reset email sent to $email. Please check your inbox.'));
      } catch (e) {
        emit(ShowAlert(e.toString().replaceFirst("Exception: ", "")));
      }
    });
  }
}