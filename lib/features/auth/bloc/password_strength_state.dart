import 'package:flutter/material.dart';

enum PasswordStrength { empty, weak, fair, strong }

extension PasswordStrengthX on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:  return '';
      case PasswordStrength.weak:   return 'Weak';
      case PasswordStrength.fair:   return 'Fair';
      case PasswordStrength.strong: return 'Strong';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:  return Colors.transparent;
      case PasswordStrength.weak:   return Colors.red;
      case PasswordStrength.fair:   return Colors.amber;
      case PasswordStrength.strong: return Colors.green;
    }
  }

  int get filledSegments {
    switch (this) {
      case PasswordStrength.empty:  return 0;
      case PasswordStrength.weak:   return 1;
      case PasswordStrength.fair:   return 2;
      case PasswordStrength.strong: return 3;
    }
  }
}
