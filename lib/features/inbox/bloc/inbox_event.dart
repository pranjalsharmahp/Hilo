import 'package:equatable/equatable.dart';
import 'package:hilo/features/inbox/inbox_model.dart';

abstract class InboxEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInbox extends InboxEvent {
  final String userEmail;

  LoadInbox(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}

class SelectConversation extends InboxEvent {
  final Conversation conversation;

  SelectConversation(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

class InitializeInbox extends InboxEvent {
  final String userEmail;

  InitializeInbox(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}
