import 'package:flutter/material.dart';
import 'package:hilo/socket/socket_service.dart';

void showAddConversationDialog(
  BuildContext context,
  String currentUserEmail,
  VoidCallback onSuccess,
) {
  final _formKey = GlobalKey<FormState>();
  String _otherUserEmail = '';
  String message = '';
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Conversation'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Other User Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onChanged: (value) {
                  _otherUserEmail = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Message'),
                onChanged: (value) {
                  message = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Call the service to add the conversation
                // For example:
                // InboxService.addConversation(currentUserEmail, _otherUserEmail, message);
                await SocketService().sendMessage(
                  currentUserEmail,
                  _otherUserEmail,
                  message,
                );
                onSuccess();
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}
