import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_toolkit/src/data_bloc/data_bloc.dart';
import 'package:meta/meta.dart';

part 'comparator.dart';

part 'filter_predicate.dart';

part 'list_params.dart';

part 'immutable_transform_list.dart';

List<T> _transform<T>(List<T> originalList, ListParams<T>? params) {
  return _ImmutableTransformList<T>(
    originalList: originalList,
    transformList: (list) {
      if (params == null) {
        return list;
      }
      final copy = [...list];
      copy.sort(params.comparator.compare);

      for (final filter in params.filters) {
        copy.retainWhere(filter.test);
      }
      return copy;
    },
  );
}

void _$onLoaded<T>(
  Emitter<DataS<List<T>>> emit,
  List<T> data, {
  ListParams<T>? params,
}) {
  final originalList =
      data is _ImmutableTransformList<T> ? data._originalList : data;
  final list = _transform(originalList, params);

  emit(LoadedDataS(list, params: params));
}

abstract class ListBloc<T> extends InternalDataBloc<List<T>, ListParams<T>> {
  ListBloc({
    List<T>? initialList,
    ListParams<T>? initialParams,
  }) : super(
          overridedOnLoaded: _$onLoaded,
          initialState: initialList != null
              ? LoadedDataS(_transform(initialList, initialParams),
                  params: initialParams)
              : UnloadedDataS(),
        );

  @override
  FutureOr<List<T>> loadData(
    DataS<List<T>> oldState,
    LoadDataE<ListParams<T>> event,
  ) {
    return [];
  }
}
