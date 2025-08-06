abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  final String role; // 'vendor' or 'customer'

  LoginSubmitted({
    required this.email,
    required this.password,
    required this.role,
  });
}
