import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextArea extends StatelessWidget {
  const CustomTextArea({
    super.key,
    required this.label,
    required this.hintText,
    required this.textEditingController,
    required this.validator,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final String label;
  final String hintText;
  final TextEditingController textEditingController;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;

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
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: minLines,
          maxLines: maxLines,
          style: AppTextStyles.bodyLg,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hintText: hintText,
            hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textDisabled),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: validator,
        ),
      ],
    );
  }
}
