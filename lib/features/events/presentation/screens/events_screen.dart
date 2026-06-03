import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/events/bloc/event_bloc.dart';
import 'package:auto_club_ai/features/events/bloc/event_event.dart';
import 'package:auto_club_ai/features/events/bloc/event_state.dart';
import 'package:auto_club_ai/features/events/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<EventBloc>().add(LoadEvents(authState.user.userId));
    }
  }

  void _confirmDelete(BuildContext context, String eventId) {
    final authState = context.read<AuthBloc>().state;
    showAppAlert(
      context,
      message: 'Are you sure you want to delete this event?',
      buttonText: 'Delete',
      showCancel: true,
      onConfirm: () {
        if (authState is Authenticated) {
          context.read<EventBloc>().add(
            DeleteEvent(eventId: eventId, userId: authState.user.userId),
          );
        }
      },
    );
  }

  bool get _isLeader {
    final authState = context.read<AuthBloc>().state;
    return authState is Authenticated && authState.user.role == 'leader';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listenWhen: (_, current) => current is EventAlert,
      listener: (context, state) {
        if (state is EventAlert) {
          final bloc = context.read<EventBloc>();
          final isSuccess = state.isSuccess;
          showAppAlert(context, message: state.message).then((_) {
            if (!mounted) return;
            bloc.add(DismissEventAlert());
            if (isSuccess) _loadEvents();
          });
        }
      },
      buildWhen: (_, current) => current is! EventAlert,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Events'),
            centerTitle: true,
          ),
          floatingActionButton: _isLeader
              ? FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  onPressed: () => context.push('/events/add'),
                  child: const Icon(Icons.add),
                )
              : null,
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(EventState state) {
    if (state is EventLoading || state is EventInitial) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (state is EventError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _loadEvents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is EventLoaded) {
      if (state.events.isEmpty) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _loadEvents(),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_outlined, size: 64, color: AppColors.textDisabled),
                        const SizedBox(height: 16),
                        Text('No Upcoming Events', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(
                          'There are no upcoming events scheduled.',
                          style: AppTextStyles.bodySm,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _loadEvents(),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            final item = state.events[index];
            return EventCard(
              event: item,
              onTap: () => context.push('/events/event/${item.eventId}'),
              onDelete: _isLeader ? () => _confirmDelete(context, item.eventId) : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
