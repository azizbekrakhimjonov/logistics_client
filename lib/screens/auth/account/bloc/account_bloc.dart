import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logistic/di/locator.dart';

import '../../../../repositories/auth_repositories.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AuthRepository _api = di.get();

  AccountBloc() : super(AccountInitial()) {
    on<AccountEvent>((event, emit) async {
      if (event is EditProfileEvent) {
        await _editProfile(event, emit);
      }
    });
  }

  _editProfile(EditProfileEvent event, Emitter<AccountState> emit) async {
    try {
      emit(AccountLoading());
      await _api.updateProfile(event.photo, event.name, event.phoneNumber);
      final dynamic data = await _api.getUser();

      emit(AccountSuccessState(data: data));
    } catch (e) {
      emit(AccountErrorState(message: e.toString()));
    }
  }
}
