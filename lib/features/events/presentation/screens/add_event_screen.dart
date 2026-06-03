import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/models/task.dart';
import 'package:auto_club_ai/core/services/ai_service.dart';
import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/events/bloc/event_bloc.dart';
import 'package:auto_club_ai/features/events/bloc/event_event.dart';
import 'package:auto_club_ai/features/events/bloc/event_state.dart';
import 'package:auto_club_ai/features/events/presentation/widgets/task_form_item.dart';
import 'package:auto_club_ai/features/events/repositories/event_repository.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:auto_club_ai/shared_widgets/custom_button.dart';
import 'package:auto_club_ai/shared_widgets/custom_text_area.dart';
import 'package:auto_club_ai/shared_widgets/date_picker_field.dart';
import 'package:auto_club_ai/shared_widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class _TaskEntry {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? deadline;
  String? assignedUserId;
  String? deadlineError;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _eventDate;
  final List<_TaskEntry> _tasks = [];
  List<Map<String, String>> _members = [];
  bool _isSubmitting = false;
  bool _isGeneratingAI = false;
  late final AIService _aiService; // Add this
  
  // Safely pull the key from the .env file!
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 


  @override
  void initState() {
    super.initState();
    _loadMembers();
    _aiService = AIService(apiKey);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    for (final t in _tasks) {
      t.dispose();
    }
    super.dispose();
  }
  Future<void> _generateTasksWithAI() async {
    // Check if they wrote an event name/description first
    if (_nameController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      showAppAlert(context, message: 'Please enter an Event Name and Description first so the AI knows what to plan.');
      return;
    }

    setState(() => _isGeneratingAI = true);
    
    try {
      final generatedTasks = await _aiService.generateTasks(
        eventName: _nameController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        eventDate: _eventDate,
      );

      // Loop through AI results and create UI forms for each
      setState(() {
        for (var task in generatedTasks) {
          final entry = _TaskEntry();
          entry.nameController.text = task.name;
          entry.descriptionController.text = task.description;
          entry.deadline = task.deadline;
          _tasks.add(entry);
        }
      });
      
      if (mounted) {
        showAppAlert(context, message: 'AI successfully generated ${generatedTasks.length} tasks! Please review and assign members.');
      }
    } catch (e) {
      if (mounted) showAppAlert(context, message: 'AI Generation failed.\n\nTechnical Details:\n$e');
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  Future<void> _loadMembers() async {
    final members = await context.read<EventRepository>().getAllMembers();
    if (mounted) setState(() => _members = members);
  }

  void _addTask() => setState(() => _tasks.add(_TaskEntry()));

  void _removeTask(int i) {
    setState(() {
      _tasks[i].dispose();
      _tasks.removeAt(i);
    });
  }


  void _submit() {
    // Validate deadline for each task manually
    bool deadlinesValid = true;
    for (final task in _tasks) {
      if (task.deadline == null) {
        task.deadlineError = 'Select a deadline';
        deadlinesValid = false;
      } else {
        task.deadlineError = null;
      }
    }

    final formValid = _formKey.currentState!.validate();

    if (!formValid || !deadlinesValid) {
      setState(() {});
      return;
    }

    setState(() => _isSubmitting = true);
    showLoadingDialog(context, message: 'Creating event...');

    final event = EventModel(
      eventId: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _eventDate!,
      venue: _venueController.text.trim(),
    );

    final tasks = _tasks.asMap().entries.map((e) {
      return TaskModel(
        taskId: '',
        eventId: '',
        name: e.value.nameController.text.trim(),
        description: e.value.descriptionController.text.trim(),
        type: 'General',
        deadline: e.value.deadline!,
        assignedTo: e.value.assignedUserId ?? '',
      );
    }).toList();

    context.read<EventBloc>().add(AddEventSubmit(event: event, tasks: tasks));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listenWhen: (_, current) => current is EventAlert,
      listener: (ctx, state) {
        if (state is EventAlert) {
          // Dismiss the loading dialog
          Navigator.of(ctx, rootNavigator: true).pop();
          setState(() => _isSubmitting = false);

          if (state.isSuccess) {
            final eventBloc = ctx.read<EventBloc>();
            final authBloc = ctx.read<AuthBloc>();
            final router = GoRouter.of(ctx);

            showAppAlert(ctx, message: state.message).then((_) {
              if (!mounted) return;
              eventBloc.add(DismissEventAlert());
              final authState = authBloc.state;
              if (authState is Authenticated) {
                eventBloc.add(LoadEvents(authState.user.userId));
              }
              router.pop();
            });
          } else {
            showAppAlert(ctx, message: state.message);
            ctx.read<EventBloc>().add(DismissEventAlert());
          }
        }
      },
      buildWhen: (_, current) => current is! EventAlert,
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Event'),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Event fields ─────────────────────────────────────────
                  CustomTextField(
                    label: 'Event Name',
                    hintText: 'e.g. Monthly Track Day',
                    textEditingController: _nameController,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Venue',
                    hintText: 'e.g. Sepang Circuit',
                    textEditingController: _venueController,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  CustomTextArea(
                    label: 'Description',
                    hintText: 'Describe the event...',
                    textEditingController: _descriptionController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  DatePickerField(
                    label: 'Event Date',
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    onChanged: (date) => _eventDate = date,
                    validator: (val) =>
                        val == null ? 'Select an event date' : null,
                  ),

                  const SizedBox(height: 28),

                  // ── Tasks section ────────────────────────────────────────
                  Row(
                    children: [
                      Text('Tasks', style: AppTextStyles.h3),
                      const SizedBox(width: 4),
                      Text(
                        '(${_tasks.length})',
                        style: AppTextStyles.bodySm,
                      ),
                      const Spacer(),
                      
                      // -- NEW AI BUTTON --
                      if (_isGeneratingAI)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 20, height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _generateTasksWithAI,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 16, color: AppColors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'AI Draft',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // -- END AI BUTTON --

                      // -- EXISTING MANUAL BUTTON --
                      GestureDetector(
                        onTap: _addTask,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 16, color: AppColors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Add',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_tasks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.checklist_outlined,
                              size: 32, color: AppColors.textDisabled),
                          const SizedBox(height: 6),
                          Text('No tasks added yet',
                              style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),

                  ...List.generate(_tasks.length, (i) {
                    final entry = _tasks[i];
                    return TaskFormItem(
                      key: ValueKey(entry),
                      index: i,
                      nameController: entry.nameController,
                      descriptionController: entry.descriptionController,
                      deadline: entry.deadline,
                      deadlineError: entry.deadlineError,
                      assignedUserId: entry.assignedUserId,
                      members: _members,
                      onDeadlineChanged: (date) => setState(() {
                        entry.deadline = date;
                        entry.deadlineError = null;
                      }),
                      onUserChanged: (userId) =>
                          setState(() => entry.assignedUserId = userId),
                      onRemove: () => _removeTask(i),
                    );
                  }),

                  const SizedBox(height: 28),

                  CustomButton(
                    text: 'Create Event',
                    onTap: _submit,
                    isLoading: _isSubmitting,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
