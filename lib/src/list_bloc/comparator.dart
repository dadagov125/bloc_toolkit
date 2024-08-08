part of 'list_bloc.dart';

abstract class Comparator<T> {
  const Comparator();

  int compare(T a, T b);
}

class DefaultComparator<T> extends Comparator<T> {
  const DefaultComparator();

  @override
  int compare(dynamic a, dynamic b) {
    return 0;
  }
}
