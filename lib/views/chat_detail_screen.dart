import 'package:assignment/bloc/message_bloc/message_bloc.dart';
import 'package:assignment/bloc/message_bloc/message_event.dart';
import 'package:assignment/bloc/message_bloc/message_state.dart';
import 'package:assignment/services/socket_service.dart';
import 'package:assignment/shared_prefrences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({required this.chatId, super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _controller = TextEditingController();

  String? userId;
  String chatUserName = 'Chat Detail';

  @override
  void initState() {
    super.initState();
    _initUserAndSocket();
  }

  Future<void> _initUserAndSocket() async {
    userId = await UserPrefs.getUserId();

    if (userId == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _socketService.connect(userId!);
    _socketService.onMessageReceived(context.read<MessageBloc>());

    context.read<MessageBloc>().add(LoadMessages(widget.chatId));
  }

  void _sendMessage() {
    final msg = _controller.text.trim();
    if (msg.isEmpty || userId == null) return;

    context.read<MessageBloc>().add(
      SendMessage(chatId: widget.chatId, senderId: userId!, content: msg),
    );

    _controller.clear();
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        title: Text(chatUserName),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessageLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MessageLoaded) {
                  final messages = state.messages;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe = message.senderId == userId;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.deepPurpleAccent : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft:
                                    isMe
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                bottomRight:
                                    isMe
                                        ? Radius.zero
                                        : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is MessageError) {
                  return Center(child: Text("Error: ${state.error}"));
                }
                return const SizedBox();
              },
            ),
          ),

          /// Message Input
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
