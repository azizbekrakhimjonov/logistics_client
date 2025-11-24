part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class GetCategories extends CategoryEvent {
  const GetCategories();

  @override
  List<Object> get props => [];
}