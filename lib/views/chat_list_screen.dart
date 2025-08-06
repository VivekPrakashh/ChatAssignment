import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/bloc/chat_bloc/chat_bloc.dart';
import 'package:assignment/bloc/chat_bloc/chat_event.dart';
import 'package:assignment/bloc/chat_bloc/chat_state.dart';
import 'package:assignment/bloc/message_bloc/message_bloc.dart';
import 'package:assignment/bloc/message_bloc/message_event.dart';
import 'package:assignment/services/message_service.dart';
import 'package:assignment/shared_prefrences/shared_preferences.dart';
import 'package:assignment/views/chat_detail_screen.dart';
import 'package:assignment/main.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  const ChatListScreen({required this.userId, super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with RouteAware {
  String? userId;
  late ChatBloc _chatBloc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final id = await UserPrefs.getUserId();

    if (!mounted) return;

    if (id == null || id.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      userId = id;
      _chatBloc = ChatBloc(messageService: MessageService());
      _chatBloc.add(FetchChatList(userId!));

      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (userId != null) {
      _chatBloc.add(FetchChatList(userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chats',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatLoaded) {
              final chats = state.chats;
              if (chats.isEmpty) {
                return const Center(child: Text('No chats available.'));
              }

              return ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatId = chat.chatId;
                  final name = chat.participants.first.name;
                  final lastMessage =
                      chat.lastMessage.isNotEmpty
                          ? chat.lastMessage
                          : 'No messages yet';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlocProvider(
                                create:
                                    (context) =>
                                        MessageBloc(MessageService())
                                          ..add(LoadMessages(chatId)),
                                child: ChatDetailScreen(chatId: chatId),
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Text(
                                chat.updatedAt != null
                                    ? _formatTime(chat.updatedAt!)
                                    : '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is ChatError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return "${time.day}/${time.month}";
    }
  }
}
