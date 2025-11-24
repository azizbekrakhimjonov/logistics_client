import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistic/di/locator.dart';
import 'package:logistic/models/history.dart';
import 'package:logistic/repositories/services_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ServicesRepository _api = di.get();

  HistoryBloc() : super(HistoryInitial()) {
    on<HistoryEvent>((event, emit) async {
      if (event is GetHistory) {
        await _getHistory(event,emit);
      }
    });
  }

  Future<void> _getHistory(HistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoadingState());
    try {
      List<History> res = await _api.getOrderHistoryList();
      print("RESSS:${res}");
      emit(HistorySuccessState(data: res));
    } catch (e) {
      emit(HistoryErrorState(message: e.toString()));
    }
  }

}
