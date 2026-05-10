import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../data/membership_repository.dart';
import 'approvals_event.dart';
import 'approvals_state.dart';

class ApprovalsBloc extends Bloc<ApprovalsEvent, ApprovalsState> {
  final MembershipRepository repository;

  ApprovalsBloc({required this.repository}) : super(ApprovalsInitial()) {
    
    // 1. Handle Fetching Data via Stream
    on<FetchPendingApplications>(
      (event, emit) async {
        emit(ApprovalsLoading());
        
        try {
          // Instead of a one-time fetch, we use emit.forEach to listen to the Firestore stream.
          // Whenever a document changes in Firebase, the UI will automatically update!
          await emit.forEach<List<Map<String, dynamic>>>(
            repository.getPendingApplications(),
            onData: (applications) => ApprovalsLoaded(applications),
            onError: (error, stackTrace) => ApprovalsError(error.toString()),
          );
        } catch (e) {
          emit(ApprovalsError("Could not connect to database."));
        }
      },
      transformer: restartable(),
    );

    // 2. Handle Accepting/Rejecting
    on<DecideApplicationEvent>((event, emit) async {
      try {
        if (event.isApproved) {
          await repository.approveMember(event.studentId); // studentId is acting as uid here
        } else {
          await repository.rejectMember(event.studentId);
        }
        // Notice we DO NOT need to emit a new list state here.
        // Because we used a Firestore Stream above, changing the role in the database
        // automatically triggers the stream to push the updated list to the UI!
      } catch (e) {
        // You might want to emit a temporary error state here to show a snackbar
        emit(ApprovalsError("Action failed: ${e.toString()}"));
      }
    });
  }
}