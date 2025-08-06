import 'package:assignment/bloc/message_bloc/message_event.dart';
import 'package:assignment/bloc/message_bloc/message_state.dart';
import 'package:assignment/models/message_model.dart';
import 'package:assignment/services/message_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageService messageService;
  final List<MessageModel> _messages = [];

  MessageBloc(this.messageService) : super(MessageInitial()) {
    /// Fetch messages from API
    on<LoadMessages>((event, emit) async {
      emit(MessageLoading());
      try {
        final msgs = await messageService.fetchMessages(event.chatId);
        _messages
          ..clear()
          ..addAll(msgs);
        emit(MessageLoaded(List.from(_messages)));
      } catch (e) {
        emit(MessageError('Failed to load messages: ${e.toString()}'));
      }
    });

    /// Send new message via API
    on<SendMessage>((event, emit) async {
      try {
        final messageData = {
          "chatId": event.chatId,
          "senderId": event.senderId,
          "content": event.content,
          "messageType": "text",
          "fileUrl": "",
        };

        await messageService.sendMessage(messageData);

        final newMessage = MessageModel(
          id: UniqueKey().toString(),
          chatId: event.chatId,
          senderId: event.senderId,
          content: event.content,
          messageType: "text",
          status: "sent",
          seenAt: null,
          sentAt: DateTime.now(),
          seenBy: [],
        );

        _messages.add(newMessage);
        emit(MessageLoaded(List.from(_messages)));
      } catch (e, stackTrace) {
        print("SendMessage Error: $e");
        print("StackTrace: $stackTrace");
        emit(MessageError('Failed to send message: ${e.toString()}'));
      }
    });

    /// Handle new message from socket
    on<NewSocketMessage>((event, emit) {
      _messages.add(event.message);
      emit(MessageLoaded(List.from(_messages)));
    });
  }
}
