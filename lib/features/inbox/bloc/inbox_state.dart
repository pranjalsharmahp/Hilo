import 'package:equatable/equatable.dart';
import 'package:hilo/features/inbox/inbox_model.dart';

abstract class InboxState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<Conversation> conversations;

  InboxLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class InboxError extends InboxState {
  final String error;

  InboxError(this.error);

  @override
  List<Object?> get props => [error];
}

class ConversationSelected extends InboxState {
  final Conversation conversation;

  ConversationSelected(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

class SignOutState extends InboxState {
  @override
  List<Object?> get props => [];
}
