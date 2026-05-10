// lib/features/membership/presentation/bloc/membership_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'membership_event.dart';
import 'membership_state.dart';

class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  MembershipBloc() : super(MembershipInitial()) {
    
    // Listen for the Submit Application Event
    on<SubmitApplicationEvent>((event, emit) async {
      // 1. Tell the UI to show a loading spinner
      emit(MembershipLoading());

      try {
        // 2. Simulate a network request to Firebase (2 seconds)
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Later, Ahmed will add actual Firebase code here:
        // await repository.submitApplication(event.name, event.studentId);

        // 3. Tell the UI it was successful
        emit(MembershipSuccess("Application for ${event.name} submitted successfully!"));
      } catch (e) {
        // 4. Tell the UI an error occurred
        emit(MembershipError("Failed to submit application. Please try again."));
      }
    });
  }
}