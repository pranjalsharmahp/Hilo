import 'dart:convert';

import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/inbox/inbox_model.dart';
import 'package:hilo/users/user.dart';
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

  static Future<List<Conversation>> loadConvosFromLocalDB(String email) async {
    final data = await LocalDatabaseService().getConversations(email);
    return data.map((row) => Conversation.fromJson(row)).toList();
  }
}
