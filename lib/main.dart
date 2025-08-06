import 'package:assignment/views/chat_detail_screen.dart';
import 'package:assignment/views/chat_list_screen.dart';
import 'package:assignment/views/login_screen.dart';
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/chatList': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return ChatListScreen(userId: userId); // pass userId to screen
        },

        '/chatDetail': (context) {
          final chatId = ModalRoute.of(context)!.settings.arguments as String;
          return ChatDetailScreen(chatId: chatId);
        },
      },
    );
  }
}
