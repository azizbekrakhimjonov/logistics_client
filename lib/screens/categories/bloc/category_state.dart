part of 'category_bloc.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

final class CategoryInitial extends CategoryState {}

class CategoryLoadingState extends CategoryState {}


class CategorySuccessState extends CategoryState {
  final List<dynamic> data;

  const CategorySuccessState({required this.data,});

  @override
  List<Object> get props => [data];
}

class CategoryErrorState extends CategoryState {
  final String message;

  const CategoryErrorState({required this.message});

  @override
  List<Object> get props => [message];
}