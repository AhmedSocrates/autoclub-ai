import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/user.dart';
import '../../../../features/auth/repositories/user_repository.dart';
import '../../bloc/edit_task_cubit.dart';
import '../../models/leader_event.dart';

class EditTaskSheet extends StatelessWidget {
  final LeaderEventTask? task;
  /// Upper bound for the due date picker — must be on or before the event end date.
  final DateTime? eventEndDate;

  const EditTaskSheet({super.key, this.task, this.eventEndDate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditTaskCubit(task: task),
      child: _EditTaskForm(task: task, eventEndDate: eventEndDate),
    );
  }
}

// StatefulWidget only to own the TextEditingController lifetime.
class _EditTaskForm extends StatefulWidget {
  final LeaderEventTask? task;
  final DateTime? eventEndDate;
  const _EditTaskForm({this.task, this.eventEndDate});

  @override
  State<_EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<_EditTaskForm> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = context.read<UserRepository>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 4,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocBuilder<EditTaskCubit, EditTaskState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task == null ? 'Add Task' : 'Edit Task',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // ── Title ────────────────────────────────────────────
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: context.read<EditTaskCubit>().titleChanged,
                  ),
                  const SizedBox(height: 12),

                  // ── Assignees ─────────────────────────────────────────
                  StreamBuilder<List<UserModel>>(
                    stream: userRepository.streamAssignableUsers(),
                    builder: (context, snapshot) {
                      final users = snapshot.data ?? const <UserModel>[];
                      final userById = {for (final u in users) u.userId: u};
                      final userIdToName = {
                        for (final u in users) u.userId: u.name
                      };
                      final selectedUsers = state.assigneeUserIds
                          .where(userById.containsKey)
                          .map((id) => userById[id]!)
                          .toList(growable: false);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Assignees',
                                  style: theme.textTheme.labelLarge),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: users.isEmpty
                                    ? null
                                    : () async {
                                        final updated =
                                            await showModalBottomSheet<
                                                Set<String>>(
                                          context: context,
                                          isScrollControlled: true,
                                          showDragHandle: true,
                                          builder: (_) => _AssigneePickerSheet(
                                            users: users,
                                            selected: state.assigneeUserIds,
                                          ),
                                        );
                                        if (updated == null ||
                                            !context.mounted) {
                                          return;
                                        }
                                        final names = updated
                                            .where(userById.containsKey)
                                            .map((id) => userById[id]!.name)
                                            .toList(growable: false);
                                        context
                                            .read<EditTaskCubit>()
                                            .setAssignees(
                                                ids: updated, names: names);
                                      },
                                icon: const Icon(Icons.group_add_outlined),
                                label: const Text('Pick'),
                              ),
                            ],
                          ),
                          if (selectedUsers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('Unassigned'),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedUsers
                                    .map((u) => Chip(
                                          label: Text(u.name),
                                          onDeleted: () =>
                                              context
                                                  .read<EditTaskCubit>()
                                                  .removeAssignee(
                                                      u.userId, userIdToName),
                                        ))
                                    .toList(growable: false),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Due date ─────────────────────────────────────────
                  Text('Due Date', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  _DueDateField(
                    selected: state.dueDate,
                    eventEndDate: widget.eventEndDate,
                    onPick: (picked) =>
                        context.read<EditTaskCubit>().setDueDate(picked),
                    onClear: () =>
                        context.read<EditTaskCubit>().clearDueDate(),
                  ),

                  // Due-date constraint hint
                  if (widget.eventEndDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 13, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Must be on or before event end '
                          '(${DateFormat.yMd().format(widget.eventEndDate!)})',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // ── Priority ─────────────────────────────────────────
                  DropdownButtonFormField<LeaderTaskPriority>(
                    initialValue: state.priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: LeaderTaskPriority.high, child: Text('High')),
                      DropdownMenuItem(
                          value: LeaderTaskPriority.medium,
                          child: Text('Medium')),
                      DropdownMenuItem(
                          value: LeaderTaskPriority.low, child: Text('Low')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        context.read<EditTaskCubit>().priorityChanged(v);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Save ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.canSave
                          ? () {
                              final id = widget.task?.id ??
                                  'tsk_${DateTime.now().microsecondsSinceEpoch}';
                              final updated = LeaderEventTask(
                                id: id,
                                title: state.title.trim(),
                                priority: state.priority,
                                assigneeUserIds: state.assigneeUserIds
                                    .toList(growable: false),
                                assigneeNames:
                                    List.unmodifiable(state.assigneeNames),
                                dueDate: state.dueDate,
                              );
                              Navigator.of(context).pop(updated);
                            }
                          : null,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Due date field widget ────────────────────────────────────────────────────

class _DueDateField extends StatelessWidget {
  final DateTime? selected;
  final DateTime? eventEndDate;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;

  const _DueDateField({
    required this.selected,
    required this.onPick,
    required this.onClear,
    this.eventEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isOverdue = selected != null &&
        selected!.isBefore(today);
    final isToday = selected != null &&
        selected!.year == today.year &&
        selected!.month == today.month &&
        selected!.day == today.day;

    Color borderColor = colorScheme.outline;
    Color labelColor = colorScheme.onSurface;
    if (isOverdue) {
      borderColor = colorScheme.error;
      labelColor = colorScheme.error;
    } else if (isToday) {
      borderColor = Colors.orange;
      labelColor = Colors.orange.shade800;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final lastDate = eventEndDate ??
            DateTime(now.year + 5);
        final picked = await showDatePicker(
          context: context,
          firstDate: today,
          lastDate: lastDate,
          initialDate: selected != null &&
                  !selected!.isBefore(today) &&
                  !selected!.isAfter(lastDate)
              ? selected!
              : today,
          helpText: eventEndDate != null
              ? 'Pick due date (max: ${DateFormat.yMd().format(eventEndDate!)})'
              : 'Pick due date',
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 18, color: labelColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected == null
                    ? 'Pick due date'
                    : DateFormat.yMMMd().format(selected!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected == null
                          ? colorScheme.onSurfaceVariant
                          : labelColor,
                    ),
              ),
            ),
            if (selected != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 18, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Assignee picker sheet ────────────────────────────────────────────────────

class _AssigneePickerSheet extends StatelessWidget {
  final List<UserModel> users;
  final Set<String> selected;

  const _AssigneePickerSheet({
    required this.users,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssigneePickerCubit(selected),
      child: _AssigneePickerView(users: users),
    );
  }
}

class _AssigneePickerView extends StatelessWidget {
  final List<UserModel> users;
  const _AssigneePickerView({required this.users});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AssigneePickerCubit, Set<String>>(
      builder: (context, selected) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 4,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Pick assignees',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: context.read<AssigneePickerCubit>().clear,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return CheckboxListTile(
                        value: selected.contains(u.userId),
                        title: Text(u.name),
                        onChanged: (_) =>
                            context.read<AssigneePickerCubit>().toggle(u.userId),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop({...selected}),
                    child: Text('Done (${selected.length})'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
