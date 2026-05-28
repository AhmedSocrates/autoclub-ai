import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onComplete;

  const TaskCard({super.key, required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.status && task.deadline.isBefore(DateTime.now());
    final deadlineColor = isOverdue ? AppColors.accentOrange : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.status ? AppColors.border : AppColors.borderDark,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: name + status badge ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: AppTextStyles.h3.copyWith(
                      color: task.status ? AppColors.textDisabled : AppColors.textPrimary,
                      decoration: task.status ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (task.status)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 13, color: AppColors.black),
                        const SizedBox(width: 4),
                        Text('Done', style: AppTextStyles.label.copyWith(color: AppColors.black)),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Event name + type chips ──────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (task.eventName.isNotEmpty)
                  _Chip(label: task.eventName, icon: Icons.event_outlined),
                _Chip(label: task.type, icon: Icons.label_outline),
              ],
            ),

            const SizedBox(height: 10),

            // ── Description ─────────────────────────────────────────────
            Text(
              task.description,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // ── Deadline + action ────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: deadlineColor),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(task.deadline),
                  style: AppTextStyles.bodySm.copyWith(color: deadlineColor),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Overdue',
                    style: AppTextStyles.label.copyWith(color: AppColors.accentOrange),
                  ),
                ],
                const Spacer(),
                if (!task.status)
                  GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Mark Complete',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Completion message (if done) ─────────────────────────────
            if (task.status && task.completionMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.completionMessage,
                  style: AppTextStyles.bodySm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
