part of 'list_bloc.dart';

@immutable
class _ImmutableTransformList<T> extends UnmodifiableListView<T> {
  _ImmutableTransformList({
    required List<T> originalList,
    required List<T> Function(List<T> list) transformList,
  })  : _originalList = UnmodifiableListView(originalList),
        super(transformList(originalList));

  final UnmodifiableListView<T> _originalList;
}
