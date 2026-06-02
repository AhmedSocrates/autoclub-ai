import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onMarkComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Reminder banner (due within 10 days) ──────────────────
            if (!isCompleted && task.isDueSoon)
              _ReminderBanner(daysLeft: task.daysUntilDue),
            // ── Overdue banner ─────────────────────────────────────────
            if (!isCompleted && task.isOverdue)
              _OverdueBanner(context: context),
            // ── Due today banner ───────────────────────────────────────
            if (!isCompleted && task.isDueToday)
              _DueTodayBanner(),

            // ── Card body ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isCompleted
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(isCompleted: isCompleted),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 8),
                    _DueDateRow(task: task),
                  ],
                  if (!isCompleted && onMarkComplete != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonal(
                        onPressed: onMarkComplete,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 16),
                            SizedBox(width: 6),
                            Text('Mark as Complete'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Banners ──────────────────────────────────────────────────────────────────

class _ReminderBanner extends StatelessWidget {
  final int daysLeft;
  const _ReminderBanner({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: Colors.amber.shade50,
      child: Row(
        children: [
          Icon(Icons.alarm_rounded, size: 15, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Text(
            daysLeft == 1
                ? 'Due tomorrow — complete this soon!'
                : 'Due in $daysLeft days — don\'t forget!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  final BuildContext context;
  const _OverdueBanner({required this.context});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 15, color: colorScheme.onErrorContainer),
          const SizedBox(width: 6),
          Text(
            'Overdue — please complete this task!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueTodayBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 15, color: Colors.orange.shade800),
          const SizedBox(width: 6),
          Text(
            'Due today — finish before end of day!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Due date row ─────────────────────────────────────────────────────────────

class _DueDateRow extends StatelessWidget {
  final TaskModel task;
  const _DueDateRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    final IconData icon;
    final String prefix;

    if (task.isCompleted) {
      color = colorScheme.onSurfaceVariant;
      icon = Icons.event_available_rounded;
      prefix = 'Due ';
    } else if (task.isOverdue) {
      color = colorScheme.error;
      icon = Icons.warning_amber_rounded;
      prefix = 'Overdue · ';
    } else if (task.isDueToday) {
      color = Colors.orange.shade700;
      icon = Icons.schedule_rounded;
      prefix = 'Due today · ';
    } else if (task.isDueSoon) {
      color = Colors.amber.shade800;
      icon = Icons.alarm_rounded;
      prefix = 'Due ';
    } else {
      color = colorScheme.onSurfaceVariant;
      icon = Icons.event_rounded;
      prefix = 'Due ';
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$prefix${DateFormat.yMMMd().format(task.dueDate!)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: (task.isOverdue ||
                        task.isDueToday ||
                        task.isDueSoon)
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool isCompleted;
  const _StatusChip({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        isCompleted ? 'Done' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCompleted
              ? colorScheme.onSecondaryContainer
              : colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: isCompleted
          ? colorScheme.secondaryContainer
          : colorScheme.primaryContainer,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
