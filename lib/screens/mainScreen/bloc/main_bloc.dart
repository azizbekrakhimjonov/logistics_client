import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistic/models/active_order.dart';
import 'package:logistic/models/preorder.dart';
import 'package:logistic/models/user.dart';
import 'package:logistic/models/user_content.dart';
import 'package:logistic/repositories/auth_repositories.dart';
import 'package:logistic/repositories/services_repository.dart';

import '../../../di/locator.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final AuthRepository _api = di.get();
  final ServicesRepository _service = di.get();


  MainBloc() : super(MainInitial()) {
    on<MainEvent>((event, emit) async {
      if (event is GetUser) {
        await _getUser(event, emit);
      } else
      if (event is PreOrderEvent){
        await _preOrder(event, emit);
      } 
      if (event is GetOrderEvent){
        await _getOrder(event, emit);
      }
    });
  }

  Future<void> _getUser(MainEvent event, Emitter<MainState> emit) async {
    emit(MainLoadingState());
    try {
      dynamic res = await _api.checkUser();

      print("RESSS:${res}");
      emit(MainSuccessState(data: res));
    } catch (e) {
      emit(MainErrorState(message: e.toString()));
    }
  }

  Future<void> _preOrder(PreOrderEvent event, Emitter<MainState> emit) async {
    emit(PreOrderLoadingState());
    try {
      dynamic res = await _service.preOrder(event.data);

      print(res);
      emit(PreOrderSuccessState(id:res));
    } catch (e) {
      print("BlocError: ${e}");
      emit(PreOrderErrorState(message: e.toString()));
    }
  }
  
  Future<void> _getOrder(GetOrderEvent event, Emitter<MainState> emit) async {
    emit(GetOrderLoadingState());
    try {
      ActiveOrder res = await _service.getOrderDetail(event.id);

      print(res);
      emit(GetOrderSuccessState(data:res));
    } catch (e) {
      print("BlocError: ${e}");
      emit(GetOrderErrorState(message: e.toString()));
    }
  }
   
}
