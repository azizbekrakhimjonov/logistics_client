import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistic/di/locator.dart';
import 'package:logistic/repositories/services_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ServicesRepository _api = di.get();

  CategoryBloc() : super(CategoryInitial()) {
    on<CategoryEvent>((event, emit) async {
      if (event is GetCategories){
          await _getCategories(event,emit);
      }
    });
  }

    Future<void> _getCategories(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoadingState());
    try {
      List<dynamic> res = await _api.getCategories();

      // print(res);
      emit(CategorySuccessState(data: res));
    } catch (e) {
      
      emit(CategoryErrorState(message: e.toString()));
    }
  }
}
