import 'package:assignment/bloc/message_bloc/message_bloc.dart';
import 'package:assignment/bloc/message_bloc/message_event.dart';
import 'package:assignment/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  /// Initialize and connect socket with userId
  void connect(String userId) {
    _socket = IO.io('http://45.129.87.38:6065', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket connected');
      _socket.emit('join', userId);
    });

    _socket.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket.onError((err) => print('⚠️ Socket error: $err'));
  }

  /// Send message to server via socket
  void sendMessage(Map<String, dynamic> message) {
    print('📤 Sending message: $message');
    _socket.emit("sendMessage", message);
  }

  /// Listen for new messages and update BLoC
  void onMessageReceived(MessageBloc messageBloc) {
    _socket.on('receive_message', (data) {
      try {
        final newMessage = MessageModel.fromJson(data);
        print('📥 Received message: ${newMessage.content}');
        messageBloc.add(NewSocketMessage(newMessage));
      } catch (e) {
        print('❗ Error parsing socket message: $e');
      }
    });
  }

  /// Disconnect and dispose socket
  void dispose() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    _socket.dispose();
    print('🛑 Socket disposed');
  }
}
