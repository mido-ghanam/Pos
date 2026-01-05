abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginOtpSent extends LoginState {
  final String message;
  final String username;
  LoginOtpSent({required this.message, required this.username});
}

class LoginSuccess extends LoginState {
  final String username;
  LoginSuccess(this.username);
}

class LoginError extends LoginState {
  final String error;
  LoginError(this.error);
}
