part of 'list_bloc.dart';

// ignore: one_member_abstracts
abstract class FilterPredicate<T> {
  const FilterPredicate();

  bool test(T e);
}
