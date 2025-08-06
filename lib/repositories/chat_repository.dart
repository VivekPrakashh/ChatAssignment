import 'package:assignment/models/chat_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRepository {
  final String baseUrl = 'http://45.129.87.38:6065';

  Future<List<ChatModel>> fetchChats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/user-chats/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ChatModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat list');
    }
  }
}
