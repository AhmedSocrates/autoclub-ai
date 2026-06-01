import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/events/models/event_with_task_count.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventWithTaskCount event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isSoon = daysUntil >= 0 && daysUntil <= 7;
    final dateColor = isSoon ? AppColors.accentOrange : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: event.taskCount > 0 ? AppColors.borderDark : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name + task count badge ──────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(event.name, style: AppTextStyles.h3),
                  ),
                  const SizedBox(width: 8),
                  _TaskBadge(count: event.taskCount),
                ],
              ),

              const SizedBox(height: 8),

              // ── Date ────────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: dateColor),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('EEE, dd MMM yyyy • HH:mm').format(event.date),
                    style: AppTextStyles.bodySm.copyWith(color: dateColor),
                  ),
                  if (isSoon) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Soon',
                      style: AppTextStyles.label.copyWith(color: AppColors.accentOrange),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // ── Description ──────────────────────────────────────────────
              Text(
                event.description,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final int count;
  const _TaskBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final hasTasks = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasTasks ? AppColors.accentGold : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: hasTasks ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 12,
            color: hasTasks ? AppColors.black : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            hasTasks ? '$count ${count == 1 ? 'task' : 'tasks'}' : 'No tasks',
            style: AppTextStyles.label.copyWith(
              color: hasTasks ? AppColors.black : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
