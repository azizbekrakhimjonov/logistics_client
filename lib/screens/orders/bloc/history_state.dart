part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  
  @override
  List<Object> get props => [];
}

final class HistoryInitial extends HistoryState {}

class HistoryLoadingState extends HistoryState {}

class HistorySuccessState extends HistoryState {
  final List<History> data;

  const HistorySuccessState({required this.data});

  @override
  List<Object> get props => [data];
}

class HistoryErrorState extends HistoryState {
  final String message;

  const HistoryErrorState({required this.message});

  @override
  List<Object> get props => [message];
}