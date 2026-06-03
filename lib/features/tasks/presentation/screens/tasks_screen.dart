import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_bloc.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_event.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_state.dart';
import 'package:auto_club_ai/features/tasks/presentation/widgets/complete_task_dialog.dart';
import 'package:auto_club_ai/features/tasks/presentation/widgets/task_card.dart';
import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TaskBloc>().add(LoadUserTasks(authState.user.userId));
    }
  }

  void _showCompleteDialog(String taskId, String eventId, String taskName) {
    showDialog(
      context: context,
      builder: (_) => CompleteTaskDialog(
        taskName: taskName,
        onConfirm: (message) {
          context.read<TaskBloc>().add(CompleteTask(taskId, eventId, message));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (_, current) => current is TaskAlert,
      listener: (context, state) {
        if (state is TaskAlert) {
          showAppAlert(context, message: state.message);
          context.read<TaskBloc>().add(DismissTaskAlert());
          _loadTasks();
        }
      },
      buildWhen: (_, current) => current is! TaskAlert,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Tasks'),
            centerTitle: true,
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(TaskState state) {
    if (state is TaskLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (state is TaskError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(state.message, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _loadTasks,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TaskLoaded) {
      if (state.tasks.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.checklist_rounded, size: 64, color: AppColors.textDisabled),
                const SizedBox(height: 16),
                Text('No Tasks Assigned', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'You have no tasks assigned to you yet.',
                  style: AppTextStyles.bodySm,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      final pending = state.tasks.where((t) => !t.status).toList();
      final completed = state.tasks.where((t) => t.status).toList();

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _loadTasks(),
        child: ListView(
          children: [
            if (pending.isNotEmpty) ...[
              _SectionLabel('Pending (${pending.length})'),
              ...pending.map((task) => TaskCard(
                    task: task,
                    onMarkComplete: () =>
                        _showCompleteDialog(task.taskId, task.eventId, task.name),
                  )),
            ],
            if (completed.isNotEmpty) ...[
              _SectionLabel('Completed (${completed.length})'),
              ...completed.map((task) => TaskCard(task: task)),
            ],
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
    );
  }
}
