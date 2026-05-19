import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../../../core/models/task.dart';
import 'widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
        listenWhen: (_, current) => current is TasksError,
        listener: (context, state) {
          if (state is TasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading || state is TasksInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          List<TaskModel> tasks = [];
          if (state is TasksLoaded) tasks = state.tasks;

          if (tasks.isEmpty) {
            return _EmptyState();
          }

          final pending = tasks.where((t) => !t.isCompleted).toList();
          final completed = tasks.where((t) => t.isCompleted).toList();

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context
                    .read<TasksBloc>()
                    .add(LoadMyTasksEvent(authState.user.userId));
              }
            },
            child: CustomScrollView(
              slivers: [
                if (pending.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Pending',
                    count: pending.length,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TaskCard(
                        task: pending[i],
                        onMarkComplete: () => ctx
                            .read<TasksBloc>()
                            .add(MarkTaskCompleteEvent(pending[i].taskId)),
                      ),
                      childCount: pending.length,
                    ),
                  ),
                ],
                if (completed.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Completed',
                    count: completed.length,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TaskCard(task: completed[i]),
                      childCount: completed.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rounded, size: 80, color: colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'No Tasks Assigned',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks assigned by your admin will appear here.',
              textAlign: TextAlign.center,
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
