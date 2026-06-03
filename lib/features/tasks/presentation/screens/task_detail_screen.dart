import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/tasks_bloc.dart';
import '../../bloc/tasks_event.dart';
import '../../bloc/tasks_state.dart';
import '../../../../core/models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        // Always read the freshest version of the task from the live stream
        TaskModel? task;
        if (state is TasksLoaded) {
          try {
            task = state.tasks.firstWhere((t) => t.taskId == taskId);
          } catch (_) {
            task = null;
          }
        }

        if (task == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _TaskDetailView(task: task);
      },
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  final TaskModel task;
  const _TaskDetailView({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status banner ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.secondaryContainer
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: isCompleted
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // ── Reminder notice ──────────────────────────────────────────
            if (!isCompleted && task.isDueSoon) ...[
              const SizedBox(height: 12),
              _ReminderNotice(
                message: task.daysUntilDue == 1
                    ? '⏰ Due tomorrow — complete this task soon!'
                    : '⏰ Due in ${task.daysUntilDue} days — don\'t forget!',
                color: Colors.amber.shade800,
                background: Colors.amber.shade50,
              ),
            ] else if (!isCompleted && task.isDueToday) ...[
              const SizedBox(height: 12),
              _ReminderNotice(
                message: '⏰ Due today — finish before end of day!',
                color: Colors.orange.shade800,
                background: Colors.orange.shade50,
              ),
            ] else if (!isCompleted && task.isOverdue) ...[
              const SizedBox(height: 12),
              _ReminderNotice(
                message: '⚠️ This task is overdue — please complete it now!',
                color: colorScheme.onErrorContainer,
                background: colorScheme.errorContainer,
              ),
            ],

            const SizedBox(height: 24),

            // ── Title ────────────────────────────────────────────────────
            Text(
              task.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                decoration:
                    isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
            ),

            if (task.eventContext != null &&
                task.eventContext!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_rounded,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    task.eventContext!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Description ──────────────────────────────────────────────
            if (task.description.isNotEmpty) ...[
              _SectionLabel('Description'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Details grid ─────────────────────────────────────────────
            _SectionLabel('Details'),
            const SizedBox(height: 8),
            _DetailCard(children: [
              _DetailRow(
                icon: Icons.person_rounded,
                label: 'Assigned to',
                value: task.assignedToName.isNotEmpty
                    ? task.assignedToName
                    : 'You',
              ),
              const Divider(height: 1),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Assigned on',
                value: DateFormat.yMMMd().format(task.createdAt),
              ),
              if (task.dueDate != null) ...[
                const Divider(height: 1),
                _DueDateDetailRow(task: task),
              ],
              if (task.eventContext != null &&
                  task.eventContext!.isNotEmpty) ...[
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.event_note_rounded,
                  label: 'Event',
                  value: task.eventContext!,
                ),
              ],
            ]),

            const SizedBox(height: 32),

            // ── Mark complete button ──────────────────────────────────────
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context
                        .read<TasksBloc>()
                        .add(MarkTaskCompleteEvent(task.taskId, task.eventId, ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Task marked as complete!'),
                          ],
                        ),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Complete'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: colorScheme.onSecondaryContainer, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Task Completed',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

}


class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DueDateDetailRow extends StatelessWidget {
  final TaskModel task;
  const _DueDateDetailRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color valueColor;
    final String label;
    final IconData icon;

    if (task.isCompleted) {
      valueColor = colorScheme.onSurface;
      label = 'Due date';
      icon = Icons.event_available_rounded;
    } else if (task.isOverdue) {
      valueColor = colorScheme.error;
      label = 'Overdue!';
      icon = Icons.warning_amber_rounded;
    } else if (task.isDueToday) {
      valueColor = Colors.orange.shade700;
      label = 'Due today';
      icon = Icons.schedule_rounded;
    } else {
      valueColor = colorScheme.onSurface;
      label = 'Due date';
      icon = Icons.event_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: valueColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            DateFormat.yMMMd().format(task.dueDate!),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReminderNotice extends StatelessWidget {
  final String message;
  final Color color;
  final Color background;
  const _ReminderNotice({
    required this.message,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
