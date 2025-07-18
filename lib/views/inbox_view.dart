import 'package:flutter/material.dart';
import 'package:hilo/dialogs/add_conversation_dialog.dart';
import 'package:hilo/inbox/inbox_model.dart';
import 'package:hilo/inbox/inbox_service.dart';

class InboxScreen extends StatefulWidget {
  final String userEmail;
  const InboxScreen({super.key, required this.userEmail});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddConversationDialog(context, widget.userEmail, () {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Inbox')),
      body: FutureBuilder<List<Conversation>>(
        future: InboxService.fetchConversations(widget.userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final conversations = snapshot.data!;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, i) {
              final convo = conversations[i];
              return ListTile(
                title: Text(convo.otherUserEmail),
                subtitle: Text(
                  '${convo.lastSenderEmail == widget.userEmail ? "You" : convo.otherUserEmail}: ${convo.lastMessage}',
                  style: TextStyle(
                    fontWeight:
                        convo.lastSenderEmail == widget.userEmail
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                trailing: Text(convo.lastUpdated.toString().substring(0, 16)),
                onTap: () {
                  // Navigate to chat with convo.otherUserEmail
                },
              );
            },
          );
        },
      ),
    );
  }
}
