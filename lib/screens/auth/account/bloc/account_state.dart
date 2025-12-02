part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();
  
  @override
  List<Object> get props => [];
}

final class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSuccessState extends AccountState {
  final dynamic data;
  const AccountSuccessState({required this.data});

  @override 
  List<Object> get props =>[data];

}

class AccountErrorState extends AccountState {
  final String message;
  const AccountErrorState({required this.message});

  @override 
  List<Object> get props =>[message];
}
// class EditPhoneSuccessState extends AccountState {

// }