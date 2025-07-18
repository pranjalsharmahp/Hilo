import 'dart:convert';

import 'package:hilo/inbox/inbox_model.dart';
import 'package:http/http.dart' as http;

class InboxService {
  static const String baseUrl = 'https://hilo-backend-ozkp.onrender.com';
  static Future<List<Conversation>> fetchConversations(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/inbox?email=$email'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final List<dynamic> jsonList = jsonMap['data'];
      return jsonList.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }
}
