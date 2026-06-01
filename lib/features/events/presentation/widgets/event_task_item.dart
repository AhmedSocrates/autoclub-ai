import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTaskItem extends StatelessWidget {
  final TaskModel task;

  const EventTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.status && task.deadline.isBefore(DateTime.now());
    final deadlineColor =
        isOverdue ? AppColors.accentOrange : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.status ? AppColors.border : AppColors.borderDark,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: description + status badge ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.description.isNotEmpty ? task.description : task.name,
                  style: AppTextStyles.h3.copyWith(
                    color: task.status
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                    decoration:
                        task.status ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (task.status)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 13, color: AppColors.black),
                      const SizedBox(width: 4),
                      Text('Done',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.black)),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppColors.accentOrange.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOverdue
                          ? AppColors.accentOrange
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    isOverdue ? 'Overdue' : 'Pending',
                    style: AppTextStyles.label.copyWith(
                      color: isOverdue
                          ? AppColors.accentOrange
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Assigned to ──────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                task.assignedToName.isNotEmpty
                    ? task.assignedToName
                    : task.assignedTo,
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Deadline ─────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: deadlineColor),
              const SizedBox(width: 5),
              Text(
                DateFormat('dd MMM yyyy').format(task.deadline),
                style: AppTextStyles.bodySm.copyWith(color: deadlineColor),
              ),
              if (isOverdue) ...[
                const SizedBox(width: 6),
                Text(
                  '· Overdue',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.accentOrange),
                ),
              ],
            ],
          ),

          // ── Completion message ───────────────────────────────────────────
          if (task.status && task.completionMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(task.completionMessage,
                        style: AppTextStyles.bodySm),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
