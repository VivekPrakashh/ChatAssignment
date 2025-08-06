import 'package:assignment/models/message_model.dart';

abstract class MessageEvent {}

/// Load messages for a specific chat
class LoadMessages extends MessageEvent {
  final String chatId;

  LoadMessages(this.chatId);
}

/// Send a new message (text or file, but currently only handling text)
class SendMessage extends MessageEvent {
  final String chatId;
  final String senderId;
  final String content;

  SendMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
  });
}

/// Receive a new message via socket and update UI
class NewSocketMessage extends MessageEvent {
  final MessageModel message;

  NewSocketMessage(this.message);
}
