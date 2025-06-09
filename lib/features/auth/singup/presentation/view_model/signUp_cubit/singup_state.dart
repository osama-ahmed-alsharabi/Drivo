abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String phoneNumber;

  SignupSuccess({required this.phoneNumber});
}

class SignupOtpResent extends SignupState {
  final String phoneNumber;

  SignupOtpResent({required this.phoneNumber});
}

class SignupVerificationSuccess extends SignupState {
  final String userType;

  SignupVerificationSuccess({required this.userType});
}

class SignupFailure extends SignupState {
  final String error;

  SignupFailure(this.error);
}
