class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String status;
  final DateTime? seenAt;
  final List<String> seenBy;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.status,
    this.seenAt,
    required this.seenBy,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? '',
      status: json['status'] ?? '',
      seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
      seenBy: List<String>.from(json['seenBy'] ?? []),
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}
