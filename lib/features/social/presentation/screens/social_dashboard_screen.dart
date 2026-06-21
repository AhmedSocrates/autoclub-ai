import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../events/presentation/widgets/social_scheduler_sheet.dart';
import '../../../events/repositories/event_repository.dart';
import '../../data/social_repository.dart';
import '../../models/scheduled_post.dart';

class SocialDashboardScreen extends StatefulWidget {
  const SocialDashboardScreen({super.key});

  @override
  State<SocialDashboardScreen> createState() => _SocialDashboardScreenState();
}

class _SocialDashboardScreenState extends State<SocialDashboardScreen> {
  final SocialRepository _socialRepository = SocialRepository();

  Future<void> _openEventPicker() async {
    final eventRepository = context.read<EventRepository>();
    final events = await eventRepository.getEvents();

    if (!mounted) return;

    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create an event first to schedule a post for it.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<EventModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventPickerSheet(events: events),
    );

    if (selected == null || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialSchedulerSheet(event: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEventPicker,
        backgroundColor: AppColors.black,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: StreamBuilder<List<ScheduledPost>>(
        stream: _socialRepository.streamScheduledPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 3));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load scheduled posts.',
                style: AppTextStyles.bodyMd,
              ),
            );
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) => _buildPostCard(posts[index]),
          );
        },
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
              Icons.campaign_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 20),
          Text('No Scheduled Posts', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Tap + to create an announcement for an event.',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(ScheduledPost post) {
    final statusColor = switch (post.status) {
      ScheduledPostStatus.posted => Colors.green.shade800,
      ScheduledPostStatus.failed => AppColors.accentOrange,
      ScheduledPostStatus.pending => AppColors.textSecondary,
    };
    final statusLabel = switch (post.status) {
      ScheduledPostStatus.posted => 'Posted',
      ScheduledPostStatus.failed => 'Failed',
      ScheduledPostStatus.pending => 'Pending',
    };

    final preview = post.telegramMessage.isNotEmpty
        ? post.telegramMessage
        : post.facebookCaption;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  post.eventName,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.label.copyWith(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEE, d MMM yyyy • HH:mm').format(post.scheduledTime),
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: 10),
          Text(
            preview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: post.targetPlatforms
                .map((p) => Chip(
                      label: Text(p == 'facebook' ? 'Facebook' : 'Telegram'),
                      labelStyle: AppTextStyles.label,
                      backgroundColor: AppColors.surfaceLight,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EventPickerSheet extends StatelessWidget {
  final List<EventModel> events;

  const _EventPickerSheet({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Pick an Event', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(event.name, style: AppTextStyles.bodyLg),
                  subtitle: Text(
                    DateFormat('EEE, d MMM yyyy').format(event.date),
                    style: AppTextStyles.bodySm,
                  ),
                  onTap: () => Navigator.of(context).pop(event),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
