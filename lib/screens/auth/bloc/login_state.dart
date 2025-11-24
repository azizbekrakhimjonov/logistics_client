part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitialState extends LoginState {
  const LoginInitialState();

  @override
  List<Object> get props => [];
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();

  @override
  List<Object?> get props => [];
}

class LoginFailState extends LoginState {
  final String message;

  const LoginFailState({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoginSuccessState extends LoginState {
  const LoginSuccessState();

  @override
  List<Object?> get props => [];
}
