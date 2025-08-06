abstract class ChatEvent {}

class FetchChatList extends ChatEvent {
  final String userId;

  FetchChatList(this.userId);
}
