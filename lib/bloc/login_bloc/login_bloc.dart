import 'package:assignment/bloc/login_bloc/login_events.dart';
import 'package:assignment/bloc/login_bloc/login_state.dart';
import 'package:assignment/models/login_response_model.dart';
import 'package:assignment/services/api_service.dart';
import 'package:assignment/services/message_service.dart';
import 'package:assignment/shared_prefrences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/models/chat_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiService apiService;
  final MessageService messageService = MessageService();

  LoginBloc(this.apiService) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final rawResponse = await apiService.login(
          email: event.email,
          password: event.password,
          role: event.role,
        );

        print("Login API raw response: \$rawResponse");

        final loginResponse = LoginResponseModel.fromJson(rawResponse);
        final user = loginResponse.data.user;

        await UserPrefs.saveUserData(user.id, user.role);
        print("Saving user: id = \${user.id}, role = \${user.role}");

        emit(LoginSuccess(user.id));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }

  Future<List<ChatModel>> fetchChats(String userId) async {
    try {
      return await messageService.fetchChats(userId);
    } catch (e) {
      print('Error fetching chats: \$e');
      rethrow;
    }
  }
}
