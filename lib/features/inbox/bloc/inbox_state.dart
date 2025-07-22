import 'package:equatable/equatable.dart';
import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/users/user.dart';

abstract class InboxState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<Conversation> conversations;

  final List<User> users;

  InboxLoaded(this.conversations, this.users);

  @override
  List<Object?> get props => [conversations, users];
}

class InboxError extends InboxState {
  final String error;

  InboxError(this.error);

  @override
  List<Object?> get props => [error];
}

class InboxUninitialized extends InboxState {}

class ConversationSelected extends InboxState {
  final Conversation conversation;

  ConversationSelected(this.conversation);

  @override
  List<Object?> get props => [conversation];
}
