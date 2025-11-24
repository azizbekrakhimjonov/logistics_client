part of 'main_bloc.dart';

sealed class MainState extends Equatable {
  const MainState();
  
  @override
  List<Object> get props => [];
}

final class MainInitial extends MainState {}

class MainLoadingState extends MainState {}

class MainSuccessState extends MainState {
  final UserContent data;

  const MainSuccessState({required this.data});

  @override
  List<Object> get props => [data];
}

class MainErrorState extends MainState {
  final String message;

  const MainErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

// preorder states

class PreOrderLoadingState extends MainState {}
class PreOrderSuccessState extends MainState {
  final int id;

  const PreOrderSuccessState({required this.id});

  @override
  List<Object> get props => [id];
}

class PreOrderErrorState extends MainState {
  final String message;

  const PreOrderErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class GetOrderLoadingState extends MainState {}
class GetOrderSuccessState extends MainState {
  final ActiveOrder data;

  const GetOrderSuccessState({required this.data});

  @override
  List<Object> get props => [data];
}

class GetOrderErrorState extends MainState {
  final String message;

  const GetOrderErrorState({required this.message});

  @override
  List<Object> get props => [message];
}