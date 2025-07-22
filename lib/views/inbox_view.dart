import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hilo/dialogs/add_conversation_dialog.dart';
import 'package:hilo/features/auth/bloc/auth_bloc.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'package:hilo/features/inbox/bloc/inbox_state.dart';

import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/chat_view.dart';
import 'package:hilo/views/login/login_view.dart';

class InboxScreen extends StatelessWidget {
  final String userEmail;
  const InboxScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InboxBloc()..add(LoadInbox(userEmail)),
      child: InboxView(userEmail: userEmail),
    );
  }
}

class InboxView extends StatelessWidget {
  final String userEmail;
  const InboxView({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddConversationDialog(context, userEmail, () {
            context.read<InboxBloc>().add(LoadInbox(userEmail));
          });
        },
        child: Icon(Icons.add),
      ),
      body: BlocListener<InboxBloc, InboxState>(
        listener: (context, state) async {
          if (state is ConversationSelected) {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ChatView(
                      currentUserEmail: userEmail,
                      otherUserEmail: state.conversation.otherUserEmail,
                    ),
              ),
            );
            if (result == true) {
              context.read<InboxBloc>().add(LoadInbox(userEmail));
            }
          }
        },
        child: BlocBuilder<InboxBloc, InboxState>(
          builder: (context, state) {
            if (state is InboxLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is InboxError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            if (state is InboxLoaded) {
              final conversations = state.conversations;
              final users = state.users;
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];
                  final user = users[index];
                  final isSentByUser = convo.lastSenderEmail == userEmail;
                  return InkWell(
                    onTap: () {
                      context.read<InboxBloc>().add(SelectConversation(convo));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                users[index].profilePictureUrl != null
                                    ? NetworkImage(user.profilePictureUrl!)
                                    : null,
                            child: Text(
                              convo.otherUserEmail[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  convo.otherUserName!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${isSentByUser ? "You" : convo.otherUserEmail}: ${convo.lastMessage}",
                                  style: TextStyle(
                                    fontWeight:
                                        isSentByUser
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            convo.lastUpdated.toString().substring(
                              11,
                              16,
                            ), // HH:mm
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
