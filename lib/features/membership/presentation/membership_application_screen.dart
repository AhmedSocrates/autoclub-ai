import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/membership_bloc.dart';
import '../bloc/membership_event.dart';
import '../bloc/membership_state.dart';
import '../data/membership_repository.dart';

class MembershipApplicationScreen extends StatelessWidget {
  const MembershipApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MembershipRepository();
    return BlocProvider(
      create: (_) => MembershipBloc(repository: repository),
      child: _MembershipApplicationView(repository: repository),
    );
  }
}

class _MembershipApplicationView extends StatefulWidget {
  final MembershipRepository repository;

  const _MembershipApplicationView({required this.repository});

  @override
  State<_MembershipApplicationView> createState() =>
      _MembershipApplicationViewState();
}

class _MembershipApplicationViewState
    extends State<_MembershipApplicationView> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  final _whyPositionController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedCommittee;

  static const _committees = ['Technical', 'Events', 'Media', 'HR'];

  @override
  void dispose() {
    _positionController.dispose();
    _whyPositionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Application'),
        centerTitle: true,
      ),
      body: StreamBuilder<bool>(
        stream: widget.repository.getRegistrationStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final isOpen = snapshot.data ?? false;
          return isOpen ? _buildForm(context) : _buildClosedView(context);
        },
      ),
    );
  }

  Widget _buildClosedView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_clock_outlined,
                size: 80, color: colorScheme.secondary),
            const SizedBox(height: 24),
            Text(
              'Registrations Closed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Membership applications are not currently being accepted.\nPlease check back later or contact the club committee.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.user;

    return BlocConsumer<MembershipBloc, MembershipState>(
      listener: (context, state) {
        if (state is MembershipSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else if (state is MembershipError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MembershipSuccess) {
          return _buildSuccessView(context);
        }

        final isLoading = state is MembershipLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(
                          'Applying as: ${user.name}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCommittee,
                  decoration: const InputDecoration(
                    labelText: 'Committee',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  items: _committees
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged:
                      isLoading ? null : (val) => setState(() => _selectedCommittee = val),
                  validator: (val) =>
                      val == null ? 'Please select a committee' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please enter the position you are applying for'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _whyPositionController,
                  enabled: !isLoading,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Why this position?',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please explain why you want this position'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  enabled: !isLoading,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Relevant Experience',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please describe your relevant experience'
                      : null,
                ),
                const SizedBox(height: 28),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                        onPressed: () =>
                            _submitForm(context, user.userId, user.name),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Submit Application'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your application is under review. You will be notified once a decision has been made.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, String uid, String userName) {
    if (_formKey.currentState!.validate()) {
      context.read<MembershipBloc>().add(
            SubmitApplicationEvent(
              uid: uid,
              userName: userName,
              committee: _selectedCommittee!,
              position: _positionController.text.trim(),
              whyPosition: _whyPositionController.text.trim(),
              experience: _experienceController.text.trim(),
            ),
          );
    }
  }
}
