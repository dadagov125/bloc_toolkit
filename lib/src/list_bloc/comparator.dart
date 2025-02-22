part of 'list_bloc.dart';

// ignore: one_member_abstracts
abstract class Comparator<T> {
  const Comparator();

  int compare(T a, T b);
}

class DefaultComparator<T> extends Comparator<T> {
  const DefaultComparator();

  @override
  // ignore: avoid_annotating_with_dynamic
  int compare(dynamic a, dynamic b) => 0;
}
