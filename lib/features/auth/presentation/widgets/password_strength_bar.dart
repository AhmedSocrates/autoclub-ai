import 'package:auto_club_ai/features/auth/bloc/password_strength_state.dart';
import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;
  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              final filled = index < strength.filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? strength.color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          strength.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: strength.color,
          ),
        ),
      ],
    );
  }
}
