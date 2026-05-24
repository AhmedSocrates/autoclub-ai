import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/leader_event.dart';
import 'widgets/edit_task_sheet.dart';
import 'widgets/priority_pill.dart';

class LeaderEventDetailScreen extends StatefulWidget {
  final LeaderEvent event;
  const LeaderEventDetailScreen({super.key, required this.event});

  @override
  State<LeaderEventDetailScreen> createState() => _LeaderEventDetailScreenState();
}

class _LeaderEventDetailScreenState extends State<LeaderEventDetailScreen> {
  late LeaderEvent _event = widget.event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Lab'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(_event),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _EventHeaderCard(
            name: _event.name,
            subtitle: 'Manual tasks • ${_event.tasks.length} items',
            trailing: TextButton(
              onPressed: () async {
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear tasks?'),
                    content: const Text(
                      'This removes all tasks from this event (you can add them again later).',
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
                if (shouldClear != true) return;
                setState(() {
                  _event = LeaderEvent(
                    id: _event.id,
                    name: _event.name,
                    startDate: _event.startDate,
                    endDate: _event.endDate,
                    tasks: const [],
                  );
                });
              },
              child: const Text('Clear tasks'),
            ),
          ),
          const SizedBox(height: 14),
          ..._event.tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TaskCard(
                  task: task,
                  onEdit: () async {
                    final updated = await showModalBottomSheet<LeaderEventTask>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      backgroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => EditTaskSheet(task: task),
                    );
                    if (!mounted || updated == null) return;
                    setState(() {
                      _event = LeaderEvent(
                        id: _event.id,
                        name: _event.name,
                        startDate: _event.startDate,
                        endDate: _event.endDate,
                        tasks: _event.tasks
                            .map((t) => t.id == updated.id ? updated : t)
                            .toList(growable: false),
                      );
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _event = LeaderEvent(
                        id: _event.id,
                        name: _event.name,
                        startDate: _event.startDate,
                        endDate: _event.endDate,
                        tasks: _event.tasks
                            .where((t) => t.id != task.id)
                            .toList(growable: false),
                      );
                    });
                  },
                ),
              )),
          if (_event.tasks.isEmpty)
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
  }
}

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.borderDark),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PriorityPill(priority: task.priority),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.assigneeNames.isEmpty
                      ? 'Unassigned'
                      : task.assigneeNames.join(', '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
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
