import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'package:hilo/features/inbox/bloc/inbox_state.dart';
import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/features/inbox/inbox_service.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc() : super(InboxInitial()) {
    on<LoadInbox>((event, emit) async {
      emit(InboxLoading());
      try {
        final convos = await InboxService.loadConvosFromLocalDB(
          event.userEmail,
        );

        final localDbService = LocalDatabaseService();

        for (Conversation convo in convos) {
          final otherUserName = await localDbService.getUserByEmail(
            convo.otherUserEmail,
          );
          convo.otherUserName = otherUserName?['name'] ?? convo.otherUserEmail;
        }

        emit(InboxLoaded(convos));
      } catch (e) {
        emit(InboxError(e.toString()));
      }
    });
    on<SelectConversation>((event, emit) {
      emit(ConversationSelected(event.conversation));
      // After this, you may choose to emit InboxLoaded again to "reset" the state if needed
    });
    on<SignOut>((event, emit) async {
      try {
        await FirebaseAuth.instance.signOut();
        emit(SignOutState());
      } catch (e) {
        emit(InboxError(e.toString()));
      }
    });
  }
}
