import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hilo/crud/local_database_service.dart';
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
  String? otherProfileUrl; // Don't use late; assign during fetch.

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
    _loadProfileUrl(); // Fetch the other user's profile photo URL.

    SocketService().onMessageReceived = (data) {
      final msg = Message.fromJson(data);
      final shouldReload =
          (msg.senderEmail == widget.currentUserEmail &&
              msg.receiverEmail == widget.otherUserEmail) ||
          (msg.senderEmail == widget.otherUserEmail &&
              msg.receiverEmail == widget.currentUserEmail);
      if (shouldReload) {
        _chatBloc.add(
          LoadMessages(
            user1: widget.currentUserEmail,
            user2: widget.otherUserEmail,
          ),
        );
      }
    };
  }

  Future<void> _loadProfileUrl() async {
    final url = await LocalDatabaseService().getProfileUrl(
      widget.otherUserEmail,
    );
    setState(() {
      otherProfileUrl = url;
    });
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
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      otherProfileUrl != null && otherProfileUrl!.isNotEmpty
                          ? NetworkImage(otherProfileUrl!)
                          : null,
                  child:
                      (otherProfileUrl == null || otherProfileUrl!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.otherUserEmail,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            elevation: 0.5,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatLoaded) {
                      final messages = state.messages;
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
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
                              margin: const EdgeInsets.symmetric(vertical: 6),
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
                                    isMe
                                        ? Colors.blueAccent.withOpacity(0.2)
                                        : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                      isMe
                                          ? const Radius.circular(16)
                                          : const Radius.circular(0),
                                  bottomRight:
                                      isMe
                                          ? const Radius.circular(0)
                                          : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
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
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.timestamp.substring(11, 16),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.check,
                                          size: 14,
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
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
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
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black87),
                        onPressed: _sendMessage,
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
