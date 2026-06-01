import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/shared_widgets/custom_dropdown_field.dart';
import 'package:auto_club_ai/shared_widgets/custom_text_area.dart';
import 'package:auto_club_ai/shared_widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskFormItem extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final DateTime? deadline;
  final String? deadlineError;
  final String? assignedUserId;
  final List<Map<String, String>> members;
  final void Function(DateTime) onDeadlineChanged;
  final void Function(String?) onUserChanged;
  final VoidCallback onRemove;

  const TaskFormItem({
    super.key,
    required this.index,
    required this.nameController,
    required this.descriptionController,
    required this.deadline,
    this.deadlineError,
    required this.assignedUserId,
    required this.members,
    required this.onDeadlineChanged,
    required this.onUserChanged,
    required this.onRemove,
  });

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) onDeadlineChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Text('Task ${index + 1}', style: AppTextStyles.h3),
                const Spacer(),
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Name ──────────────────────────────────────────────────────
            CustomTextField(
              label: 'Task Name',
              hintText: 'e.g. Set up registration booth',
              textEditingController: nameController,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // ── Description ───────────────────────────────────────────────
            CustomTextArea(
              label: 'Description',
              hintText: 'What needs to be done?',
              textEditingController: descriptionController,
              minLines: 2,
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // ── Deadline ──────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('Deadline', style: AppTextStyles.bodyLg),
                ),
                GestureDetector(
                  onTap: () => _pickDeadline(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: deadlineError != null
                            ? const Color(0xFFD32F2F)
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            deadline != null
                                ? DateFormat('EEE, dd MMM yyyy').format(deadline!)
                                : 'Select deadline',
                            style: deadline != null
                                ? AppTextStyles.bodyLg
                                : AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textDisabled),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                if (deadlineError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 14),
                    child: Text(
                      deadlineError!,
                      style: AppTextStyles.bodySm
                          .copyWith(color: const Color(0xFFD32F2F)),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Assigned to ───────────────────────────────────────────────
            CustomDropdownField<String>(
              label: 'Assign To',
              hintText: 'Select a member',
              value: assignedUserId,
              items: members
                  .map(
                    (m) => DropdownMenuItem<String>(
                      value: m['userId'],
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m['role'] ?? '',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onUserChanged,
              validator: (v) => v == null ? 'Select a member' : null,
            ),
          ],
        ),
      ),
    );
  }
}
