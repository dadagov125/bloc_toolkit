part of 'list_bloc.dart';

@immutable
class ListParams<T> {
  const ListParams({
    this.filters = const [],
    this.comparator = const DefaultComparator(),
  });

  final List<FilterPredicate<T>> filters;

  final Comparator<T> comparator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListParams &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          comparator == other.comparator;

  @override
  int get hashCode => filters.hashCode ^ comparator.hashCode;
}
