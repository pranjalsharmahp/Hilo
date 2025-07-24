class Message {
  final String senderEmail;
  final String receiverEmail;
  final String content;
  final String timestamp;
  final String messageId;
  final bool isSeen;

  Message({
    required this.isSeen,
    required this.messageId,
    required this.senderEmail,
    required this.receiverEmail,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final isSeenValue = json['is_seen'];
    bool isSeenBool = false;

    if (isSeenValue is int) {
      isSeenBool = isSeenValue >= 1;
    } else if (isSeenValue is bool) {
      isSeenBool = isSeenValue;
    }

    return Message(
      isSeen: isSeenBool,
      senderEmail: json['sender_email'],
      receiverEmail: json['receiver_email'],
      content: json['content'],
      messageId: json['message_id'],
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}
