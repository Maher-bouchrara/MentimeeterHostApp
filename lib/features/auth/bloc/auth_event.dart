part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  const SignupRequested({
    required this.displayName,
    required this.email,
    required this.password,
  });
  final String displayName;
  final String email;
  final String password;
  @override
  List<Object?> get props => [displayName, email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthRequested extends AuthEvent {
  const CheckAuthRequested();
}
