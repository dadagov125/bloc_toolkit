import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' show droppable;
import 'package:bloc_toolkit/src/exception/data_exception.dart';
import 'package:bloc_toolkit/src/exception/unhandled_data_exception.dart';
import 'package:meta/meta.dart' show immutable, protected;

part 'data_event.dart';

part 'data_state.dart';

part 'data_loaded_state.dart';

part 'data_unloaded_state.dart';

part 'data_extension.dart';

part 'data_union.dart';

//------ types
typedef OnLoading<Data> = void Function(Emitter<DataS<Data>> emit);

typedef OnLoaded<Data, Params> = void Function(
  Emitter<DataS<Data>> emit,
  Data data, {
  Params? params,
});

typedef OnLoadingError<Data, Params> = void Function(
  DataException error,
  UnloadedDataS<Data> state,
  Emitter<DataS<Data>> emit, {
  Params? params,
});

typedef OnReloading<Data, Params> = void Function(
  Emitter<DataS<Data>> emit,
  LoadedS<Data, Params> oldState,
  ReloadDataE<Params> event,
);

typedef OnReloadingError<Data, Params> = void Function(
  DataException error,
  LoadedS<Data, Params> state,
  Emitter<DataS<Data>> emit,
);

//----- Top lvl Functions

void _$onLoading<Data>(Emitter<DataS<Data>> emit) {
  emit(const LoadingDataS());
}

void _$onLoaded<Data, Params>(
  Emitter<DataS<Data>> emit,
  Data data, {
  Params? params,
}) {
  emit(LoadedDataS(data, params: params));
}

void _$onLoadingError<Data, Params>(
  DataException error,
  UnloadedDataS<Data> state,
  Emitter<DataS<Data>> emit, {
  Params? params,
}) {
  emit(
    LoadingDataErrorS(
      error,
      params: params,
    ),
  );
  emit(const UnloadedDataS());
}

void _$onReloading<Data, Params>(
  Emitter<DataS<Data>> emit,
  LoadedS<Data, Params> oldState,
  ReloadDataE<Params> event,
) {
  emit(
    ReloadingDataS(
      oldState,
      isNextLoading: event.isNextLoading,
    ),
  );
}

void _$onReloadingError<Data, Params>(
  DataException error,
  LoadedS<Data, Params> state,
  Emitter<DataS<Data>> emit,
) {
  emit(ReloadingDataErrorS(state, error));
  emit(LoadedDataS(state.data, params: state.params));
}

//----- Internal bloc
abstract class InternalDataBloc<Data, Params>
    extends Bloc<DataE<Params>, DataS<Data>> {
  InternalDataBloc({
    EventTransformer<DataE<Params>>? transformer,
    OnLoading<Data>? overridedOnLoading,
    OnLoaded<Data, Params>? overridedOnLoaded,
    OnLoadingError<Data, Params>? overridedOnLoadingError,
    OnReloading<Data, Params>? overridedOnReloading,
    OnReloadingError<Data, Params>? overridedOnReloadingError,
  })  : onLoading = overridedOnLoading ?? _$onLoading,
        onLoaded = overridedOnLoaded ?? _$onLoaded,
        onLoadingError = overridedOnLoadingError ?? _$onLoadingError,
        onReloading = overridedOnReloading ?? _$onReloading,
        onReloadingError = overridedOnReloadingError ?? _$onReloadingError,
        super(const UnloadedDataS()) {
    on<DataE<Params>>(
      _handleEvent,
      transformer: transformer ?? droppable(),
    );
  }

  final OnLoading<Data> onLoading;
  final OnReloading<Data, Params> onReloading;
  final OnLoaded<Data, Params> onLoaded;
  final OnLoadingError<Data, Params> onLoadingError;
  final OnReloadingError<Data, Params> onReloadingError;

  @protected
  FutureOr<Data> loadData(DataS<Data> oldState, LoadDataE<Params> event);

  FutureOr<void> _handleEvent(DataE<Params> event, Emitter<DataS<Data>> emit) {
    if (event is ReloadDataE<Params>) {
      return _reload(
        event,
        emit,
      );
    } else if (event is LoadDataE<Params>) {
      return _load(
        event,
        emit,
      );
    }
    if (event is UpdateDataE<Data, Params>) {
      return _update(event, emit);
    }
    if (event is InitializeDataE<Data, Params>) {
      return _initialize(event, emit);
    }
  }

  Future<void> _load(
    LoadDataE<Params> event,
    Emitter<DataS<Data>> emit,
  ) async {
    final oldState = state;
    final params = event.params;
    if (oldState is! UnloadedDataS<Data>) {
      return;
    }
    try {
      onLoading(emit);
      final data = await loadData(oldState, event);

      onLoaded(emit, data, params: params);
    } on DataException catch (error) {
      onLoadingError(
        error,
        oldState,
        emit,
        params: params,
      );
    } on Object catch (error, stackTrace) {
      onLoadingError(
        UnhandledDataException(error: error, stackTrace: stackTrace),
        oldState,
        emit,
        params: params,
      );
    }
  }

  Future<void> _reload(
    ReloadDataE<Params> event,
    Emitter<DataS<Data>> emit,
  ) async {
    final oldState = state;
    final params = event.params;
    if (oldState is! LoadedS<Data, Params>) {
      return;
    }
    try {
      onReloading(emit, oldState, event);
      final data = await loadData(oldState, event);
      onLoaded(emit, data, params: params);
    } on DataException catch (error) {
      onReloadingError(error, oldState, emit);
    } on Object catch (error, stackTrace) {
      onReloadingError(
        UnhandledDataException(error: error, stackTrace: stackTrace),
        oldState,
        emit,
      );
    }
  }

  FutureOr<void> _update(
    UpdateDataE<Data, Params> event,
    Emitter<DataS<Data>> emit,
  ) {
    final oldState = state;
    if (oldState is LoadedS<Data, Params>) {
      try {
        onLoaded(
          emit,
          event.update(
            oldState.data,
          ),
          params: event.params ?? oldState.params,
        );
      } on Object catch (error, stackTrace) {
        onReloadingError(
          UnhandledDataException(error: error, stackTrace: stackTrace),
          oldState,
          emit,
        );
      }
    }
  }

  FutureOr<void> _initialize(
    InitializeDataE<Data, Params> event,
    Emitter<DataS<Data>> emit,
  ) {
    if (state is UnloadedDataS<Data>) {
      onLoaded(
        emit,
        event.data,
        params: event.params,
      );
    }
  }
}

//----- public bloc
abstract class DataBloc<Data, Params> extends InternalDataBloc<Data, Params> {
  DataBloc({
    EventTransformer<DataE<Params>>? transformer,
    OnLoadingError<Data, Params>? overridedOnLoadingError,
    OnReloadingError<Data, Params>? overridedOnReloadingError,
  }) : super(
          transformer: transformer,
          overridedOnLoadingError: overridedOnLoadingError,
          overridedOnReloadingError: overridedOnReloadingError,
        );
}
