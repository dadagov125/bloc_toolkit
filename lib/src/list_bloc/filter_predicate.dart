
part of 'list_bloc.dart';

abstract class FilterPredicate<T> {
  const FilterPredicate();

  bool test(T e);
}
