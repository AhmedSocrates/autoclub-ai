import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/bloc/tasks_state.dart';
import '../../../core/models/task.dart';
import '../../tasks/presentation/task_detail_screen.dart';
import '../../tasks/presentation/widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final uid = authState.user.userId;
      if (_loadedUserId != uid) {
        _loadedUserId = uid;
        context.read<TasksBloc>().add(LoadMyTasksEvent(uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, taskState) {
            final tasks = taskState is TasksLoaded ? taskState.tasks : <TaskModel>[];
            final pendingCount = tasks.where((t) => !t.isCompleted).length;
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final recentTasks = tasks.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            Text(
                              user?.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          user != null && user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      (user?.role ?? 'member').toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    labelStyle:
                        TextStyle(color: colorScheme.onSecondaryContainer),
                  ),

                  const SizedBox(height: 28),

                  // ── Overview stats ─────────────────────────────────────
                  Text(
                    'Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'My Tasks',
                          value: taskState is TasksLoading
                              ? '…'
                              : '$pendingCount',
                          icon: Icons.checklist_rounded,
                          color: colorScheme.primary,
                          onTap: () => context.go('/my-tasks'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Completed',
                          value: taskState is TasksLoading
                              ? '…'
                              : '$completedCount',
                          icon: Icons.check_circle_outline,
                          color: colorScheme.tertiary,
                          onTap: () => context.go('/my-tasks'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Events',
                          value: '0',
                          icon: Icons.event_outlined,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Members',
                          value: '0',
                          icon: Icons.group_outlined,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Recent Tasks ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Tasks',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (tasks.isNotEmpty)
                        TextButton(
                          onPressed: () => context.go('/my-tasks'),
                          child: const Text('See all'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (taskState is TasksLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (recentTasks.isEmpty)
                    _NoTasksPlaceholder()
                  else
                    // Cards without horizontal padding since they're in the scroll view
                    Column(
                      children: recentTasks
                          .map((t) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: TaskCard(
                                  task: t,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TaskDetailScreen(taskId: t.taskId),
                                    ),
                                  ),
                                  onMarkComplete: t.isCompleted
                                      ? null
                                      : () => context
                                          .read<TasksBloc>()
                                          .add(MarkTaskCompleteEvent(t.taskId)),
                                ),
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoTasksPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined,
                size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No tasks assigned yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
