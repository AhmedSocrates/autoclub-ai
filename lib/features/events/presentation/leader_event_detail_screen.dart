import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/tasks/data/task_repository.dart';
import '../bloc/event_detail_cubit.dart';
import '../data/event_repository.dart';
import '../models/leader_event.dart';
import 'widgets/edit_task_sheet.dart';
import 'widgets/priority_pill.dart';

class LeaderEventDetailScreen extends StatelessWidget {
  final LeaderEvent event;
  const LeaderEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventDetailCubit(
        event,
        taskRepository: context.read<TaskRepository>(),
        eventRepository: context.read<EventRepository>(),
      ),
      child: const _LeaderEventDetailView(),
    );
  }
}

class _LeaderEventDetailView extends StatelessWidget {
  const _LeaderEventDetailView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EventDetailCubit, EventDetailState>(
      listenWhen: (prev, curr) => curr.publishStatus != prev.publishStatus,
      listener: (context, state) {
        if (state.publishStatus == PublishStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.publishedCount} task(s) published to members!',
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
          // Do NOT reset — keep PublishStatus.success to lock the button
          // until the leader edits a task.
        } else if (state.publishStatus == PublishStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.publishError ?? 'Publish failed.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
          context.read<EventDetailCubit>().resetPublishStatus();
        }
      },
      builder: (context, state) {
        final event = state.event;
        final isPublishing = state.publishStatus == PublishStatus.loading;
        final isPublished = state.publishStatus == PublishStatus.success;
        final authState = context.read<AuthBloc>().state;
        final leaderUserId =
            authState is Authenticated ? authState.user.userId : '';

        final assignedTaskCount = event.tasks
            .where((t) => t.assigneeUserIds.isNotEmpty)
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Lab'),
            centerTitle: false,
            actions: [
              // ── Publish button ──────────────────────────────────────
              if (!isPublishing)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.icon(
                    // Disabled when: nothing assigned, already published,
                    // or currently publishing.
                    onPressed: assignedTaskCount == 0 || isPublished
                        ? null
                        : () => context
                            .read<EventDetailCubit>()
                            .publishTasks(leaderUserId: leaderUserId),
                    icon: Icon(
                      isPublished
                          ? Icons.check_circle_rounded
                          : Icons.send_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isPublished
                          ? 'Published ✓'
                          : 'Publish ($assignedTaskCount)',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isPublished
                          ? Colors.green.shade600
                          : AppColors.accentGold,
                      foregroundColor:
                          isPublished ? Colors.white : AppColors.black,
                      disabledBackgroundColor: isPublished
                          ? Colors.green.shade400
                          : AppColors.accentGold.withValues(alpha: 0.35),
                      disabledForegroundColor:
                          isPublished ? Colors.white : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(event),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // ── Publish hint banner ─────────────────────────────────
              if (event.tasks.isNotEmpty && assignedTaskCount == 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Assign members to tasks, then tap Publish to send them to member dashboards.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              _EventHeaderCard(
                name: event.name,
                subtitle: 'Manual tasks • ${event.tasks.length} items',
                trailing: TextButton(
                  onPressed: () async {
                    final shouldClear = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear tasks?'),
                        content: const Text(
                          'This removes all tasks from this event.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.black,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    if (shouldClear != true || !context.mounted) return;
                    context.read<EventDetailCubit>().clearTasks();
                  },
                  child: const Text('Clear tasks'),
                ),
              ),
              const SizedBox(height: 14),
              ...event.tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TaskCard(
                      task: task,
                      onEdit: () async {
                        final updated =
                            await showModalBottomSheet<LeaderEventTask>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          backgroundColor: AppColors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24)),
                          ),
                          builder: (_) => EditTaskSheet(
                                task: task,
                                eventEndDate: event.endDate,
                              ),
                        );
                        if (!context.mounted || updated == null) return;
                        context.read<EventDetailCubit>().updateTask(updated);
                      },
                      onDelete: () =>
                          context.read<EventDetailCubit>().deleteTask(task.id),
                    ),
                  )),
              if (event.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'No tasks yet.\nAdd tasks when creating the event.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Supporting widgets ───────────────────────────────────────────────────────

class _EventHeaderCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final Widget trailing;
  const _EventHeaderCard({
    required this.name,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final LeaderEventTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAssignees = task.assigneeUserIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(
          BorderSide(
            color: hasAssignees
                ? AppColors.accentGold.withValues(alpha: 0.6)
                : AppColors.borderDark,
            width: hasAssignees ? 1.5 : 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              PriorityPill(priority: task.priority),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                hasAssignees
                    ? Icons.person_rounded
                    : Icons.person_outline,
                size: 18,
                color: hasAssignees
                    ? AppColors.accentGold
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.assigneeNames.isEmpty
                      ? 'Unassigned — tap Edit to assign a member'
                      : task.assigneeNames.join(', '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasAssignees
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
