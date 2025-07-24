import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/dialogs/add_conversation_dialog.dart';
import 'package:hilo/features/auth/bloc/auth_bloc.dart';
import 'package:hilo/features/auth/bloc/auth_event.dart';
import 'package:hilo/features/auth/firebase_auth_provider.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'package:hilo/features/inbox/bloc/inbox_state.dart';

import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/person.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/views/chat_view.dart';
import 'package:hilo/views/login/login_view.dart';
import 'package:hilo/views/profile_view.dart';

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

class InboxView extends StatefulWidget {
  final String userEmail;
  const InboxView({super.key, required this.userEmail});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  @override
  void initState() {
    super.initState();
    SocketService().onMessageReceived = (data) async {
      final otherUserEmail = data['sender_email'];
      final userData = await SocketService.fetchUserByEmail(otherUserEmail);
      LocalDatabaseService().insertUser({
        'email': userData!.email,
        'name': userData.name,
        'profile_url': userData.profilePictureUrl,
        'bio': userData.bio,
      });
      context.read<InboxBloc>().add(LoadInbox(data['receiver_email']));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () async {
              final email = FirebaseAuth.instance.currentUser?.email;
              if (email != null) {
                final user = await LocalDatabaseService().getUserByEmail(email);
                if (user != null) {
                  context.read<InboxBloc>().add(LoadProfile(user));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddConversationDialog(context, widget.userEmail, () {
            context.read<InboxBloc>().add(LoadInbox(widget.userEmail));
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocListener<InboxBloc, InboxState>(
        listener: (context, state) async {
          if (state is ConversationSelected) {
            print('state issssss Conversationselected');

            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ChatView(
                      currentUserEmail: widget.userEmail,
                      otherUserEmail: state.conversation.otherUserEmail,
                    ),
              ),
            );

            if (result == true) {
              context.read<InboxBloc>().add(LoadInbox(widget.userEmail));
            }
          }
        },
        child: BlocBuilder<InboxBloc, InboxState>(
          builder: (context, state) {
            if (state is InboxLoading) {
              return const Center(child: CircularProgressIndicator());
              // You can replace with shimmer effect
            }

            if (state is InboxError) {
              return Center(
                child: Text(
                  'Oops! ${state.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (state is LoadProfileState) {
              return ProfileView(user: state.user);
            }

            if (state is InboxLoaded) {
              print('state iisssss Inbox loaded');
              final conversations = state.conversations;
              final users = state.users;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];
                  final user = users[index];
                  final isSentByUser =
                      convo.lastSenderEmail == widget.userEmail;

                  return GestureDetector(
                    onTap: () {
                      context.read<InboxBloc>().add(SelectConversation(convo));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final profileUrl = await LocalDatabaseService()
                                  .getProfileUrl(convo.otherUserEmail);
                              final person = Person(
                                profileUrl,
                                name: convo.otherUserName ?? '',
                                email: convo.otherUserEmail,
                                bio: 'Hey! I’m using HILO',
                              );
                              context.read<InboxBloc>().add(
                                LoadProfile(person),
                              );
                            },
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  user.profilePictureUrl != null
                                      ? NetworkImage(user.profilePictureUrl!)
                                      : null,
                              backgroundColor: Colors.grey[200],
                              child:
                                  user.profilePictureUrl == ''
                                      ? const Icon(
                                        Icons.person,
                                        size: 28,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  convo.otherUserName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${isSentByUser ? "You" : convo.otherUserEmail}: ${convo.lastMessage}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSentByUser
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            convo.lastUpdated.toString().substring(11, 16),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
