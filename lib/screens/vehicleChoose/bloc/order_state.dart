part of 'order_bloc.dart';

sealed class OrderState extends Equatable {
  
  const OrderState();
  
  @override
  List<Object> get props => [];
}

final class OrderInitial extends OrderState {}

final class OrderLoadingState extends OrderState {}

class OrderSuccessState extends OrderState {
  final Order data;
  const OrderSuccessState({required this.data});

  @override 
  List<Object> get props =>[data];
}

class OrderErrorState extends OrderState {
  final String message;
  const OrderErrorState({required this.message});

  @override 
  List<Object> get props =>[message];
}

final class OrderDeleteLoadingState extends OrderState {}

class OrderDeleteSuccessState extends OrderState {
  // final Order data;
  const OrderDeleteSuccessState();

  @override 
  List<Object> get props =>[];
}

class OrderDeleteErrorState extends OrderState {
  final String message;
  const OrderDeleteErrorState({required this.message});

  @override 
  List<Object> get props =>[message];
}