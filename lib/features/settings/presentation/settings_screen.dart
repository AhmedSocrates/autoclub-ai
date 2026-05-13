import 'package:auto_club_ai/features/settings/presentation/widgets/profile_information.dart';
import 'package:auto_club_ai/features/settings/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/models/user.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared_widgets/alert.dart';
import '../../../shared_widgets/text_field.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _usernameFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _submitUsername(BuildContext context, UserModel user) {
    if (_usernameFormKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        ChangeUserName(_usernameController.text.trim(), user),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, String uid) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(DeleteAccountRequested(uid));
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listenWhen: (_, current) => current is ShowAlert,
      listener: (context, state) {
        if (state is ShowAlert) {
          showAppAlert(context, message: state.message, buttonText: 'OK');
          context.read<UserBloc>().add(DismissAlert());
          context.read<AuthBloc>().add(RefreshUserProfile());
        }
      },
      buildWhen: (_, current) => current is! ShowAlert,
      builder: (context, userState) {
        final authState = context.watch<AuthBloc>().state;
        final user = authState is Authenticated ? authState.user : null;
        final isLeader = user?.role == 'leader';
        final isEditing = userState is UsernameChangeInputRequested;
        final isLoadingUsername = userState is UsernameLoading;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              // ── Profile card ───────────────────────────────────────────────
              if (user != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProfileInformation(user: user),
                ),

              const Divider(),

              // ── Profile actions ────────────────────────────────────────────
              SectionHeader('Profile'),

              // Edit username — button or inline editor
              if (isEditing || isLoadingUsername)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _usernameFormKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Username',
                            hintText: 'New username',
                            textEditingController: _usernameController,
                            textInputAction: TextInputAction.done,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username cannot be empty';
                              }
                              if (value.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      const SizedBox(width: 8),
                      isLoadingUsername
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.check),
                              tooltip: 'Save',
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              onPressed: user != null
                                  ? () => _submitUsername(context, user)
                                  : null,
                            ),
                    ],
                  ),
                ),
              )
              else
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Edit Username'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.read<UserBloc>().add(ViewInputField()),
                ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.read<AuthBloc>().add(SignOutRequested()),
              ),

              const Divider(),

              // ── General ───────────────────────────────────────────────────
              SectionHeader('General'),
              const ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Notifications'),
                subtitle: Text('Coming in Sprint 3'),
                trailing: Icon(Icons.chevron_right),
                enabled: false,
              ),
              const ListTile(
                leading: Icon(Icons.color_lens_outlined),
                title: Text('Appearance'),
                subtitle: Text('Coming in Sprint 3'),
                trailing: Icon(Icons.chevron_right),
                enabled: false,
              ),

              // ── Admin (leader only) ────────────────────────────────────────
              if (isLeader) ...[
                const Divider(),
                SectionHeader('Admin'),
                ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Approvals Dashboard'),
                  subtitle: const Text('Review pending applications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRouter.approvals),
                ),
              ],

              const Divider(),

              // ── Danger Zone ────────────────────────────────────────────────
              SectionHeader('Danger Zone'),
              ListTile(
                leading: Icon(Icons.lock_reset_outlined, color: colorScheme.error),
                title: Text(
                  'Change Password',
                  style: TextStyle(color: colorScheme.error),
                ),
                subtitle: const Text('Send a password reset email'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.read<UserBloc>().add(ChangePasswordRequested()),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
                title: Text(
                  'Delete Account',
                  style: TextStyle(color: colorScheme.error),
                ),
                subtitle: const Text('Permanently remove your account'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDeleteConfirmation(context, user!.userId),
              ),
            ],
          ),
        );
      },
    );
  }
}


