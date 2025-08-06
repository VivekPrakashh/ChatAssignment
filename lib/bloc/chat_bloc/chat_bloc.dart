import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/bloc/chat_bloc/chat_event.dart';
import 'package:assignment/bloc/chat_bloc/chat_state.dart';
import 'package:assignment/models/chat_model.dart';
import 'package:assignment/services/message_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessageService messageService;

  ChatBloc({required this.messageService}) : super(ChatInitial()) {
    on<FetchChatList>(_onFetchChatList);
  }

  Future<void> _onFetchChatList(
    FetchChatList event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final List<ChatModel> chats = await messageService.fetchChats(
        event.userId,
      );
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatError('Failed to fetch chat list: $e'));
    }
  }
}
