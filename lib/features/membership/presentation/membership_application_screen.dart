// lib/features/membership/presentation/screens/membership_application_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/membership_bloc.dart';
import '../bloc/membership_event.dart';
import '../bloc/membership_state.dart';

// We wrap the screen in a BlocProvider so it has access to the Bloc
class MembershipApplicationScreen extends StatelessWidget {
  const MembershipApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MembershipBloc(),
      child: const _MembershipApplicationView(),
    );
  }
}

class _MembershipApplicationView extends StatefulWidget {
  const _MembershipApplicationView();

  @override
  State<_MembershipApplicationView> createState() => _MembershipApplicationViewState();
}

class _MembershipApplicationViewState extends State<_MembershipApplicationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply for Membership")),
      // BlocConsumer listens to state changes to show Snackbars, AND rebuilds the UI
      body: BlocConsumer<MembershipBloc, MembershipState>(
        listener: (context, state) {
          if (state is MembershipSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Optionally: context.go('/pending-status');
          } else if (state is MembershipError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(labelText: "Student ID", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(labelText: "Why join?", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 30),
                  
                  // The UI changes instantly based on BLoC State!
                  if (state is MembershipLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () {
                        // 1. Validate form
                        if (_formKey.currentState!.validate()) {
                          // 2. Fire the BLoC Event
                          context.read<MembershipBloc>().add(
                            SubmitApplicationEvent(
                              name: _nameController.text,
                              studentId: _studentIdController.text,
                              reason: _reasonController.text,
                            ),
                          );
                        }
                      },
                      child: const Text("SUBMIT APPLICATION"),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}