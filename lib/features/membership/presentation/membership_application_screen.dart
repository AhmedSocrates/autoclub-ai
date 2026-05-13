import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
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
  final _whyPositionController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedCommittee;
  String? _selectedPosition;

  static const _committees = ['Technical', 'Events', 'Media', 'HR'];
  static const _positions = ['Team Lead', 'Committee Member'];

  @override
  void dispose() {
    _whyPositionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Icon(
              Icons.lock_clock_outlined,
              size: 80,
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Registrations Closed',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title & Subtitle ──
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Membership',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 32,
                                    ),
                              ),
                              Text(
                                'Application',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 32,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Join our community and make an impact',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(thickness: 1.5, color: Colors.black),
                        const SizedBox(height: 32),
                        // ── Applying As ──
                        Row(
                          children: [
                            const Icon(Icons.person_outline, color: Color(0xFF4B5563), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Applying as',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: user.name,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF304D7D), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        // ── Committee ──
                        Row(
                          children: [
                            const Icon(Icons.group_outlined, color: Color(0xFF4B5563), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Committee',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedCommittee,
                          decoration: InputDecoration(
                            hintText: 'Select a committee',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          items: _committees
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => _selectedCommittee = val),
                          validator: (val) =>
                              val == null ? 'Please select a committee' : null,
                        ),
                        const SizedBox(height: 24),
                        // ── Position ──
                        Row(
                          children: [
                            const Icon(Icons.business_center_outlined, color: Color(0xFF4B5563), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Position',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedPosition,
                          decoration: InputDecoration(
                            hintText: 'Select a position',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          items: _positions
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => _selectedPosition = val),
                          validator: (val) =>
                              val == null ? 'Please select a position' : null,
                        ),
                        const SizedBox(height: 24),
                        // ── Why this position? ──
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, color: Color(0xFF4B5563), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Why this position?',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _whyPositionController,
                          enabled: !isLoading,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Describe your motivation and what you hope to contribute...',
                            hintStyle: const TextStyle(color: Colors.black38),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF304D7D), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            alignLabelWithHint: true,
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Please explain why you want this position'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        // ── Relevant Experience ──
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, color: Color(0xFF4B5563), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Relevant Experience',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _experienceController,
                          enabled: !isLoading,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Share your previous experience, skills, and achievements...',
                            hintStyle: const TextStyle(color: Colors.black38),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF304D7D), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            alignLabelWithHint: true,
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Please describe your relevant experience'
                              : null,
                        ),
                        const SizedBox(height: 32),
                        // ── Submit Button ──
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _submitForm(context, user.userId, user.name),
                                  icon: const Icon(Icons.send_outlined, size: 20),
                                  label: const Text(
                                    'Submit Application',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
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
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your application is under review. You will be notified once a decision has been made.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
              icon: const Icon(Icons.login_outlined),
              label: const Text('Go to Login'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
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
          position: _selectedPosition!,
          whyPosition: _whyPositionController.text.trim(),
          experience: _experienceController.text.trim(),
        ),
      );
    }
  }
}
