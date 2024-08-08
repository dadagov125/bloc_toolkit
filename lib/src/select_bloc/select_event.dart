part of 'select_bloc.dart';

@immutable
class SelectE<T> {
  SelectE(this.item);

  final T? item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectE &&
          runtimeType == other.runtimeType &&
          item == other.item;

  @override
  int get hashCode => item.hashCode;
}
