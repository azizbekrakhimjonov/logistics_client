part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class GetOrder extends OrderEvent {
  final int id;
  const GetOrder({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteOrder extends OrderEvent {
  final int id;
  const DeleteOrder({required this.id});

  @override
  List<Object> get props => [id];
}