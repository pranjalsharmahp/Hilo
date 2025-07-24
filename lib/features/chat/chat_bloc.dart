// chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:hilo/features/chat/chat_service.dart';
import 'package:hilo/features/chat/chat_model.dart';
import 'package:hilo/socket/socket_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());

      try {
        final messages = await ChatService.loadMessagesFromLocalDB(
          event.user1,
          event.user2,
        );
        emit(ChatLoaded(messages));
      } catch (e) {
        emit(ChatError('Failed to load messages. $e'));
      }
    });

    on<SendMessage>((event, emit) async {
      try {
        await SocketService().sendMessage(
          event.sender,
          event.receiver,
          event.content,
        );
        // reload messages after sending
        final messages = await ChatService.loadMessagesFromLocalDB(
          event.sender,
          event.receiver,
        );
        emit(ChatLoaded(messages));
      } catch (e) {
        emit(ChatError('Failed to send message.'));
      }
    });
  }
}
