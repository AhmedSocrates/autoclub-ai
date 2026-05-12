import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/membership_repository.dart';
import 'membership_event.dart';
import 'membership_state.dart';

class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  final MembershipRepository repository;

  MembershipBloc({required this.repository}) : super(MembershipInitial()) {
    on<SubmitApplicationEvent>((event, emit) async {
      emit(MembershipLoading());
      try {
        await repository.submitApplication(
          uid: event.uid,
          userName: event.userName,
          committee: event.committee,
          position: event.position,
          whyPosition: event.whyPosition,
          experience: event.experience,
        );
        emit(MembershipSuccess('Your application has been submitted successfully!'));
      } catch (e) {
        emit(MembershipError('Failed to submit application. Please try again.'));
      }
    });
  }
}
