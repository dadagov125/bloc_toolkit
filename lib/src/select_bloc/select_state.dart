part of 'select_bloc.dart';

@immutable
class SelectS<T> {
  const SelectS(this.items);

  final List<T> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectS &&
          runtimeType == other.runtimeType &&
          items == other.items;

  @override
  int get hashCode => items.hashCode;
}

@immutable
class SelectedS<T> extends SelectS<T> {
  SelectedS({required this.selected, required List<T> items}) : super(items);
  final T selected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SelectedS &&
          runtimeType == other.runtimeType &&
          selected == other.selected;

  @override
  int get hashCode => super.hashCode ^ selected.hashCode;
}
