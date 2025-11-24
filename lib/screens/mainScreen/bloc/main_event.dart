part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

class GetUser extends MainEvent {
  const GetUser();

  @override
  List<Object> get props => [];
}

class PreOrderEvent extends MainEvent {
  final PreOrder data;
  const PreOrderEvent({required this.data});

  @override
  List<Object> get props => [data];
}

class GetOrderEvent extends MainEvent {
  final int id;
  const GetOrderEvent({required this.id});

  @override
  List<Object> get props => [id];
}