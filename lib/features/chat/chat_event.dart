// chat_event.dart
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String sender;
  final String receiver;
  final String content;

  SendMessage({
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [sender, receiver, content];
}

class LoadMessages extends ChatEvent {
  final String user1;
  final String user2;
  LoadMessages({required this.user1, required this.user2});

  @override
  List<Object?> get props => [user1, user2];
}
