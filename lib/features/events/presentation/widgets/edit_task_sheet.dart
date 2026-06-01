import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/user.dart';
import '../../../../features/auth/repositories/user_repository.dart';
import '../../models/leader_event.dart';

class EditTaskSheet extends StatefulWidget {
  final LeaderEventTask? task;
  const EditTaskSheet({super.key, this.task});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late final TextEditingController _titleController;
  late LeaderTaskPriority _priority;
  Set<String> _assigneeUserIds = <String>{};
  List<String> _assigneeNames = const [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _priority = widget.task?.priority ?? LeaderTaskPriority.medium;
    _assigneeUserIds = {...(widget.task?.assigneeUserIds ?? const [])};
    _assigneeNames = [...(widget.task?.assigneeNames ?? const [])];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final userRepository = context.read<UserRepository>();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task == null ? 'Add Task' : 'Edit Task',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<UserModel>>(
              stream: userRepository.streamAssignableUsers(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? const <UserModel>[];
                final userById = {for (final u in users) u.userId: u};

                final selectedUsers = _assigneeUserIds
                    .where(userById.containsKey)
                    .map((id) => userById[id]!)
                    .toList(growable: false);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Assignees',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: users.isEmpty
                              ? null
                              : () async {
                                  final updated = await showModalBottomSheet<
                                      Set<String>>(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => _AssigneePickerSheet(
                                      users: users,
                                      selected: _assigneeUserIds,
                                    ),
                                  );

                                  if (updated == null) return;
                                  setState(() {
                                    _assigneeUserIds = {...updated};
                                    _assigneeNames = _assigneeUserIds
                                        .where(userById.containsKey)
                                        .map((id) => userById[id]!.name)
                                        .toList(growable: false);
                                  });
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
                              .map(
                                (u) => Chip(
                                  label: Text(u.name),
                                  onDeleted: () {
                                    setState(() {
                                      _assigneeUserIds.remove(u.userId);
                                      _assigneeNames = _assigneeUserIds
                                          .where(userById.containsKey)
                                          .map((id) => userById[id]!.name)
                                          .toList(growable: false);
                                    });
                                  },
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LeaderTaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: LeaderTaskPriority.high,
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: LeaderTaskPriority.medium,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: LeaderTaskPriority.low,
                  child: Text('Low'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _priority = v);
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave
                    ? () {
                        final id = widget.task?.id ??
                            'tsk_${DateTime.now().microsecondsSinceEpoch}';
                        final updated = LeaderEventTask(
                          id: id,
                          title: _titleController.text.trim(),
                          priority: _priority,
                          assigneeUserIds:
                              _assigneeUserIds.toList(growable: false),
                          assigneeNames: List.unmodifiable(_assigneeNames),
                        );
                        Navigator.of(context).pop(updated);
                      }
                    : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneePickerSheet extends StatefulWidget {
  final List<UserModel> users;
  final Set<String> selected;

  const _AssigneePickerSheet({
    required this.users,
    required this.selected,
  });

  @override
  State<_AssigneePickerSheet> createState() => _AssigneePickerSheetState();
}

class _AssigneePickerSheetState extends State<_AssigneePickerSheet> {
  late Set<String> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  onPressed: () => setState(() => _selected.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final u = widget.users[index];
                  final checked = _selected.contains(u.userId);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(u.name),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selected.add(u.userId);
                        } else {
                          _selected.remove(u.userId);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text('Done (${_selected.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
