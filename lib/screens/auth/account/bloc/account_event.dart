part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class EditProfileEvent extends AccountEvent {
  final String photo;
  final String name;
  final String phoneNumber;

  const EditProfileEvent(
      {required this.photo, required this.name, required this.phoneNumber});

  @override
  List<Object> get props => [photo, name, phoneNumber];
}
