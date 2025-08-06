class ChatModel {
  final String chatId;
  final bool isGroupChat;
  final String lastMessage;
  final List<ChatUser> participants;
  final DateTime? updatedAt; // New field

  ChatModel({
    required this.chatId,
    required this.isGroupChat,
    required this.lastMessage,
    required this.participants,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final lastMsg = json['lastMessage'];
    String lastMessageContent = '';

    if (lastMsg != null && lastMsg is Map<String, dynamic>) {
      lastMessageContent = lastMsg['content'] ?? '';
    } else if (lastMsg is String) {
      lastMessageContent = lastMsg;
    }

    return ChatModel(
      chatId: json['_id'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      lastMessage: lastMessageContent,
      participants:
          (json['participants'] as List<dynamic>? ?? [])
              .map((e) => ChatUser.fromJson(e))
              .toList(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String role;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
  factory ChatUser.empty() =>
      ChatUser(id: '', name: 'Unknown', email: 'email', role: 'role');
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
