import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html' as io;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '/di/locator.dart';

import '/repositories/auth_repositories.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _api = di.get();

  LoginBloc() : super(const LoginInitialState()) {
    on<LoginEvent>(
      (event, emit) async {
        emit(const LoginInitialState());
        if (event is LoginEnterEvent) {
          await _emitLoginEnterEvent(event, emit);
        }
        if(event is CodeEntryEvent){
          await _codeEntry(event, emit);
        }
        // if(event is RegisterEvent){
        //   await _registration(event,emit);
        // }
      },
      // transformer: sequential(),
    );
  }

  Future<void> _emitLoginEnterEvent(
    LoginEnterEvent event,
    Emitter<LoginState> emit,
  ) async {
    // if (event.username.isEmpty || event.password.isEmpty) {
    //   emit(const LoginFailState(message: "Ma'lumotlar to'liq emas"));
    //   return;
    // }
    emit(const LoginLoadingState());
    try {
      print("PHONNE:${event.phone } ${event.name}");

      await _api.login(
         event.phone,
         event.name
      );
      emit(const LoginSuccessState());
    } catch (e) {
      if (e is Response) {
        if (e.data is Map && e.data["non_field_errors"] != null) {
          emit(
            LoginFailState(
                message: "Xatolik sodir bo'ldi. ${e.data["non_field_errors"]}"),
          );
        } else {
          emit(
            LoginFailState(message: "Xatolik sodir bo'ldi. ${e.statusCode}"),
          );
        }
      } else if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown)) {
        emit(const LoginFailState(message: "Internet bilan bog'liq xatolik"));
      } else {
        emit(LoginFailState(message: "$e"));
      }
    }
  }


   Future<void> _codeEntry(
    CodeEntryEvent event,
    Emitter<LoginState> emit,
  ) async {
  
    emit(const LoginLoadingState());
    try {
      await _api.codeEntry(
         event.phone,
         event.opt
      );
      emit(const LoginSuccessState());
    } catch (e) {
      print("ERROR:$e");
      if (e is Response) {
        if (e.data is Map && e.data["error"] != null) {
          emit(
            LoginFailState(
                message: "Xatolik sodir bo'ldi. ${e.data["error"]}"),
          );
        } else {
          emit(
            LoginFailState(message: "Xatolik sodir bo'ldi. ${e.statusCode}"),
          );
        }
      } else if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown)) {
        emit(const LoginFailState(message: "Internet bilan bog'liq xatolik"));
      } else {
        emit(LoginFailState(message: "$e"));
      }
    }
  }

  // Future<void> _registration(
  //   RegisterEvent event,
  //   Emitter<LoginState> emit,
  // ) async {

  //   emit(const LoginLoadingState());
  //   try {
  //     // await _api.register(
  //     //    event.username,
  //     //    event.phone,
  //     // );
  //     emit(const LoginSuccessState());
  //   } catch (e) {
  //     if (e is Response) {
  //       if (e.data is Map && e.data["phone"][0] != null) {
  //         emit(
  //           LoginFailState(
  //               message: "Xatolik sodir bo'ldi. ${e.data["phone"][0]}"),
  //         );
  //       } else {
  //         emit(
  //           LoginFailState(message: "Xatolik sodir bo'ldi. ${e.statusCode}"),
  //         );
  //       }
  //     } else if (e is DioError && e.error is SocketException) {
  //       emit(const LoginFailState(message: "Internet bilan bog'liq xatolik"));
  //     } else {
  //       emit(LoginFailState(message: "$e"));
  //     }
  //   }
  // }

  
}
