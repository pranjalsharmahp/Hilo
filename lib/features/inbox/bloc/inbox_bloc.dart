import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'package:hilo/features/inbox/bloc/inbox_state.dart';
import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/features/inbox/inbox_service.dart';
import 'package:hilo/person.dart';
import 'package:hilo/socket/socket_service.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  bool _hasInitialized = false;
  InboxBloc() : super(InboxInitial()) {
    on<LoadInbox>((event, emit) async {
      emit(InboxLoading());
      try {
        if (!_hasInitialized) {
          await LocalDatabaseService().initialLocalSync(event.userEmail);
          SocketService().initSocket(event.userEmail);
          _hasInitialized = true;
        }
        final convos = await InboxService.loadConvosFromLocalDB(
          event.userEmail,
        );

        final localDbService = LocalDatabaseService();
        List<Person> users = [];
        for (Conversation convo in convos) {
          final user = await localDbService.getUserByEmail(
            convo.otherUserEmail,
          );
          users.add(user!);
          convo.otherUserName = user?.name ?? convo.otherUserEmail;
        }

        emit(InboxLoaded(convos, users));
      } catch (e) {
        emit(InboxError(e.toString()));
      }
    });

    on<LoadProfile>((event, emit) {
      emit(LoadProfileState(event.user));
    });
    on<SelectConversation>((event, emit) {
      emit(ConversationSelected(event.conversation));
      // After this, you may choose to emit InboxLoaded again to "reset" the state if needed
    });
  }
}
