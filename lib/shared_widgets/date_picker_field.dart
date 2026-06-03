import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends FormField<DateTime> {
  DatePickerField({
    super.key,
    required String label,
    DateTime? initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    super.validator,
    ValueChanged<DateTime>? onChanged,
  }) : super(
          initialValue: initialValue,
          builder: (FormFieldState<DateTime> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(label, style: AppTextStyles.bodyLg),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: state.context,
                      initialDate: state.value ?? DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (picked != null) {
                      state.didChange(picked);
                      onChanged?.call(picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: state.hasError
                            ? const Color(0xFFD32F2F)
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.value != null
                                ? DateFormat('EEE, dd MMM yyyy').format(state.value!)
                                : 'Select a date',
                            style: state.value != null
                                ? AppTextStyles.bodyLg
                                : AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textDisabled),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 14),
                    child: Text(
                      state.errorText!,
                      style: AppTextStyles.bodySm
                          .copyWith(color: const Color(0xFFD32F2F)),
                    ),
                  ),
              ],
            );
          },
        );
}
