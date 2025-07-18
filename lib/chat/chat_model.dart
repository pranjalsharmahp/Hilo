class Message {
  final String senderEmail;
  final String receiverEmail;
  final String content;
  final String timestamp;

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderEmail: json['sender_email'],
      receiverEmail: json['receiver_email'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }
}
