import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistic/di/locator.dart';
import 'package:logistic/models/order.dart';

import '../../../repositories/services_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final ServicesRepository _api = di.get();

  OrderBloc() : super(OrderInitial()) {
    on<OrderEvent>((event, emit) async {
      if (event is GetOrder) {
        await _getOrder(event, emit);
      }
      if (event is DeleteOrder) {
        await _deleteOrder(event, emit);
      }
    });
  }

  Future<void> _getOrder(GetOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoadingState());
    int retryCount = 0;
    Timer? timer;
    DateTime startTime = DateTime.now();
    bool isCompleted = false;

    Future<void> getOrderDetail() async {
      try {
        Order res = await _api.getPreOrderDetail(event.id);
        if (res.proposedPrices.isEmpty) {
          print("RES: $retryCount");

          // Retry for 30 seconds if response length is empty
          if (retryCount <= 10) {
            retryCount++;
            timer = Timer(const Duration(seconds: 3), getOrderDetail);
          } else {
             emit(OrderSuccessState(data: res));
          }
        } else {
          emit(OrderSuccessState(data: res));
        }
      } catch (e) {
        print("BlocError: $e");
        emit(OrderErrorState(message: e.toString()));
      }
    }

    await getOrderDetail();
    await Future.delayed(const Duration(seconds: 40));
    if (!isCompleted) {
      emit(OrderInitial());
    }
  }

  Future<void> _deleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    emit(OrderDeleteLoadingState());
    try {
      await _api.deleteOrder(event.id);

      // print(res);
      emit(const OrderDeleteSuccessState());
    } catch (e) {
      print("BlocError: $e");
      emit(OrderDeleteErrorState(message: e.toString()));
    }
  }
}
