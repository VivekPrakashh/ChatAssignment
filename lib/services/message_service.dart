import 'package:assignment/models/message_model.dart';
import 'package:assignment/models/chat_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageService {
  final String baseUrl = 'http://45.129.87.38:6065';

  Future<List<MessageModel>> fetchMessages(String chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/get-messagesformobile/$chatId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    final response = await http.post(
      Uri.parse(
        'http://45.129.87.38:6065/messages/sendMessage',
      ), // check this URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(messageData),
    );

    if (response.statusCode == 201) {
      // optionally return something if your backend responds with message JSON
      return;
    } else {
      print('Failed response: ${response.body}');
      throw Exception(
        'Failed to send message. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<ChatModel>> fetchChats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/user-chats/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((e) => ChatModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<ChatModel?> fetchChatById(String chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/user-chats/$chatId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatModel.fromJson(data); // one chat
    } else {
      return null;
    }
  }
}
