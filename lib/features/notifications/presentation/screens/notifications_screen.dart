import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/event.dart';
import '../../../tasks/bloc/task_bloc.dart';
import '../../../tasks/bloc/task_state.dart';
import '../../../tasks/bloc/tasks_bloc.dart';
import '../../../tasks/bloc/tasks_state.dart';
import '../../../events/bloc/event_bloc.dart';
import '../../../events/bloc/event_state.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import '../../../events/presentation/widgets/social_scheduler_sheet.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Pre-populated mock historical notifications for a club member
  List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Task Assigned',
      message: 'You have been assigned to: "Prepare marketing flyer for Auto Show" by Leader Mike.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.assignment,
      isRead: false,
      relatedId: 'task_marketing_flyer',
    ),
    NotificationModel(
      id: 'n2',
      title: 'Task Overdue Warning',
      message: 'Urgent: "Confirm event catering count" is past its due date!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.system,
      isRead: false,
      relatedId: 'task_catering',
    ),
    NotificationModel(
      id: 'n3',
      title: 'Task Completed',
      message: 'Sarah marked "Rent sound system" as complete.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.taskUpdate,
      isRead: true,
      relatedId: 'task_sound_system',
    ),
    NotificationModel(
      id: 'n4',
      title: 'Event Venue Updated',
      message: 'The location for "Spring Car Rally" has been changed to Speedway Arena.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.eventUpdate,
      isRead: true,
      relatedId: 'event_spring_rally',
    ),
    NotificationModel(
      id: 'n5',
      title: 'Task Assignment Log',
      message: 'Leader Mike assigned "Decorate main stage" to Alex.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.assignment,
      isRead: true,
      relatedId: 'task_decorate_stage',
    ),
    NotificationModel(
      id: 'n6',
      title: 'New Event Scheduled',
      message: 'A new event "Offroad Trail Run" has been scheduled for next Saturday.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.eventUpdate,
      isRead: true,
      relatedId: 'event_offroad_run',
    ),
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter the list based on selection
    final filteredNotifications = _notifications.where((n) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Tasks') {
        return n.type == NotificationType.taskUpdate ||
            n.type == NotificationType.assignment;
      }
      if (_selectedFilter == 'Events') {
        return n.type == NotificationType.eventUpdate;
      }
      if (_selectedFilter == 'Updates') {
        return n.type == NotificationType.system ||
            n.type == NotificationType.taskUpdate;
      }
      return true;
    }).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unreadCount > 0 ? " ($unreadCount)" : ""}'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text(
                'Read All',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Chips ───────────────────────────────────────────────────
          _buildFilterBar(),

          const Divider(height: 1, color: AppColors.border),

          // ── List of Notifications ──────────────────────────────────────────
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotificationItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Tasks', 'Events', 'Updates'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: AppColors.black,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: AppTextStyles.fontFamily,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.black : AppColors.border,
                  width: 1,
                ),
              ),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (item.type) {
      case NotificationType.assignment:
        iconData = Icons.assignment_ind_outlined;
        iconColor = AppColors.black;
        backgroundColor = AppColors.surface;
        break;
      case NotificationType.taskUpdate:
        iconData = Icons.check_circle_outline;
        iconColor = AppColors.textSecondary;
        backgroundColor = AppColors.surfaceLight;
        break;
      case NotificationType.eventUpdate:
        iconData = Icons.event_outlined;
        iconColor = AppColors.accentOrange;
        backgroundColor = const Color(0xFFFFF0EC);
        break;
      case NotificationType.system:
        iconData = Icons.warning_amber_rounded;
        iconColor = AppColors.accentGold;
        backgroundColor = const Color(0xFFFFFBEA);
        break;
    }

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: AppColors.black,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final originalIndex = _notifications.indexOf(item);
        setState(() {
          _notifications.removeAt(originalIndex);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification cleared'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.accentGold,
              onPressed: () {
                setState(() {
                  _notifications.insert(originalIndex, item);
                });
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(item),
        child: Container(
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.8),
            ),
            color: item.isRead ? Colors.transparent : const Color(0xFFF9F9F9),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Unread indicator dot ────────────────────────────────────────
              if (!item.isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                const SizedBox(width: 16),

              // ── Icon Container ──────────────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),

              const SizedBox(width: 12),

              // ── Details ─────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.bodyLg.copyWith(
                            fontWeight: item.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(item.timestamp),
                          style: AppTextStyles.label.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppTextStyles.bodySm.copyWith(
                        color: item.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'All Caught Up!',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            'You have no notifications in this category.',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }

  void _toggleReadStatus(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: !_notifications[index].isRead,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  void _handleNotificationTap(NotificationModel item) {
    // 1. Toggle read status if unread
    if (!item.isRead) {
      _toggleReadStatus(item.id);
    }

    if (item.relatedId == null || item.relatedId!.isEmpty) return;

    // 2. Try real navigation or open beautiful mock dialog details
    if (item.type == NotificationType.eventUpdate) {
      final eventState = context.read<EventBloc>().state;
      bool eventExists = false;
      if (eventState is EventLoaded) {
        eventExists = eventState.events.any((e) => e.eventId == item.relatedId);
      }

      if (eventExists) {
        context.push('/events/event/${item.relatedId}');
      } else {
        _showMockEventDialog(item);
      }
    } else if (item.type == NotificationType.taskUpdate ||
        item.type == NotificationType.assignment) {
      final taskState = context.read<TaskBloc>().state;
      final tasksState = context.read<TasksBloc>().state;
      bool taskExists = false;

      if (taskState is TaskLoaded) {
        taskExists = taskState.tasks.any((t) => t.taskId == item.relatedId);
      }
      if (!taskExists && tasksState is TasksLoaded) {
        taskExists = tasksState.tasks.any((t) => t.taskId == item.relatedId);
      }

      if (taskExists) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: item.relatedId!),
          ),
        );
      } else {
        _showMockTaskDialog(item);
      }
    }
  }

  void _showMockEventDialog(NotificationModel item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.event_note_outlined, color: AppColors.accentOrange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.h3,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Speedway Arena', style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Next Saturday • 10:00 AM', style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                // Trigger Social Scheduler sheet using dummy EventModel
                final dummyEvent = EventModel(
                  eventId: item.relatedId ?? 'event_id',
                  name: 'Spring Car Rally',
                  description: 'Our annual spring rally meet and offroad competition.',
                  date: DateTime.now().add(const Duration(days: 7)),
                  venue: 'Speedway Arena',
                );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SocialSchedulerSheet(event: dummyEvent),
                );
              },
              child: const Text('Schedule Post'),
            ),
          ],
        );
      },
    );
  }

  void _showMockTaskDialog(NotificationModel item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: AppColors.black),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.h3,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Assigned by: Leader Mike', style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.alarm, size: 16, color: AppColors.accentOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Due Date: Urgent / Overdue',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        );
      },
    );
  }
}
