import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.textEditingController,
    required this.textInputAction,
    required this.textInputType,
    required this.validator,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final String? Function(String?) validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: AppTextStyles.bodyLg),
        ),
        TextFormField(
          controller: textEditingController,
          obscureText: obscureText,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          style: AppTextStyles.bodyLg, // Slightly bigger user input text
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white, // White (primary) background
            hintText: hintText,
            hintStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.textDisabled,
            ),
            // Resting border — same thickness as focused
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.black,
                width: 1.5, // Same thickness, just changes color
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          validator: validator,
        ),
      ],
    );
  }
}