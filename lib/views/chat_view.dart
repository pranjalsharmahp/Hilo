import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/features/chat/chat_bloc.dart';
import 'package:hilo/features/chat/chat_event.dart';
import 'package:hilo/features/chat/chat_model.dart';
import 'package:hilo/features/chat/chat_state.dart';
import 'package:hilo/socket/socket_service.dart';

class ChatView extends StatefulWidget {
  final String currentUserEmail;
  final String otherUserEmail;
  const ChatView({
    super.key,
    required this.currentUserEmail,
    required this.otherUserEmail,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
    _chatBloc.add(
      LoadMessages(
        user1: widget.currentUserEmail,
        user2: widget.otherUserEmail,
      ),
    );
    SocketService().onMessageReceived = (data) {
      final msg = Message.fromJson(data);
      if ((msg.senderEmail == widget.currentUserEmail &&
              msg.receiverEmail == widget.otherUserEmail) ||
          (msg.senderEmail == widget.otherUserEmail &&
              msg.receiverEmail == widget.currentUserEmail)) {
        _chatBloc.add(
          LoadMessages(
            user1: widget.currentUserEmail,
            user2: widget.otherUserEmail,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    SocketService().onMessageReceived = null;
    _chatBloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _chatBloc.add(
      SendMessage(
        sender: widget.currentUserEmail,
        receiver: widget.otherUserEmail,
        content: text,
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (_) => _chatBloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.otherUserEmail),
            elevation: 1,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatLoaded) {
                      final messages = state.messages;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[messages.length - 1 - index];
                          final isMe =
                              msg.senderEmail == widget.currentUserEmail;
                          return Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[200] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.timestamp.substring(11, 16),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      if (isMe) ...[
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    if (state is ChatError) {
                      return Center(child: Text(state.error));
                    }
                    return Container();
                  },
                ),
              ),
              Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
