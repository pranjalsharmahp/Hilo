// chat_state.dart
import 'package:equatable/equatable.dart';
import 'package:hilo/features/chat/chat_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);

  @override
  List<Object?> get props => [error];
}

class MessageSent extends ChatState {}
