abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccessClient extends LoginState {}

class LoginSuccessDelivery extends LoginState {}

class LoginSuccessPorvider extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

class LoginSuccessProviderNeedsSetup extends LoginState {
  final Map<String, dynamic> provider;

  LoginSuccessProviderNeedsSetup({required this.provider});
}
