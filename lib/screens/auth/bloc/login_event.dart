part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginEnterEvent extends LoginEvent {
  // final String username;
  final String phone;
  final String name;

  const LoginEnterEvent({required this.phone,required this.name});

  @override
  List<Object?> get props => [phone,name];
}


class CodeEntryEvent extends LoginEvent {
  // final String username;
  final String phone;
  final String opt;

  const CodeEntryEvent({required this.phone,required this.opt});

  @override
  List<Object?> get props => [phone,opt];
}


class RegisterEvent extends LoginEvent {
  final String username;
  final String phone;

  const RegisterEvent({required this.username,required this.phone});

  @override
  List<Object?> get props => [username,phone];
}
