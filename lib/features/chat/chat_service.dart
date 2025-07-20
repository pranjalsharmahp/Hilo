import 'dart:convert';

import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/chat/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'https://hilo-backend-ozkp.onrender.com';
  static Future<List<Message>> fetchMessages(String user1, String user2) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/messages/between?user1=$user1&user2=$user2'),
    );
    if (resp.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(resp.body);

      final List<dynamic> data = parsed['data'];
      return data.map((m) => Message.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static Future<List<Message>> loadMessagesFromLocalDB(
    String user1,
    String user2,
  ) async {
    final data = await LocalDatabaseService().getMessages(user1, user2);
    return data.map((row) => Message.fromJson(row)).toList();
  }
}
