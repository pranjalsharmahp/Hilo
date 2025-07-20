class Conversation {
  final int id;
  final String user1Email;
  final String user2Email;
  final String lastMessage;
  final String lastSenderEmail;
  final DateTime lastUpdated;
  final String otherUserEmail;

  Conversation({
    required this.otherUserEmail,
    required this.id,
    required this.user1Email,
    required this.user2Email,
    required this.lastMessage,
    required this.lastSenderEmail,
    required this.lastUpdated,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUserEmail: json['other_user_email'],
      id: json['id'],
      user1Email: json['user1_email'],
      user2Email: json['user2_email'],
      lastMessage: json['last_message'],
      lastSenderEmail: json['last_sender_email'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
