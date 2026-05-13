import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_strength_state.dart';

class PasswordStrengthCubit extends Cubit<PasswordStrength> {
  PasswordStrengthCubit() : super(PasswordStrength.empty);

  void updatePassword(String password) {
    if (password.isEmpty) {
      emit(PasswordStrength.empty);
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) {
      emit(PasswordStrength.weak);
    } else if (score <= 3) {
      emit(PasswordStrength.fair);
    } else {
      emit(PasswordStrength.strong);
    }
  }
}
