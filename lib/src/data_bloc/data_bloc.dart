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

//------ types
typedef OnLoading<Data> = void Function(Emitter<DataS<Data>> emit);

typedef OnLoadingSuccess<Data> = void Function(
  Emitter<DataS<Data>> emit,
  Data data,
);

typedef OnLoadingError<Data> = void Function(
  DataException error,
  UnloadedDataS<Data> state,
  Emitter<DataS<Data>> emit,
);

typedef OnReloading<Data> = void Function(
  Emitter<DataS<Data>> emit,
  LoadedDataS<Data> oldState,
  ReloadDataE event,
);

typedef OnReloadingFinished<Data> = void Function(
  Emitter<DataS<Data>> emit,
  Data data,
);

typedef OnReloadingError<Data> = void Function(
  DataException error,
  LoadedDataS<Data> state,
  Emitter<DataS<Data>> emit,
);

//----- Functions

void _$onLoading<Data>(Emitter<DataS<Data>> emit) {
  emit(const LoadingDataS());
}

void _$onLoadingSuccess<Data>(Emitter<DataS<Data>> emit, Data data) {
  emit(LoadedDataSuccessS(data));
}

void _$onLoadingError<Data>(
  DataException error,
  UnloadedDataS<Data> state,
  Emitter<DataS<Data>> emit,
) {
  emit(LoadingDataErrorS(error));
}

void _$onReloading<Data>(
  Emitter<DataS<Data>> emit,
  LoadedDataS<Data> oldState,
  ReloadDataE event,
) {
  emit(
    ReloadingDataS(
      oldState,
      isNextLoading: event.isNextLoading,
    ),
  );
}

void _$onReloadingFinished<Data>(Emitter<DataS<Data>> emit, Data data) {
  emit(ReloadingDataFinishedS(data));
}

void _$onReloadingError<Data>(
  DataException error,
  LoadedDataS<Data> state,
  Emitter<DataS<Data>> emit,
) {
  emit(ReloadingErrorS(state, error));
  emit(LoadedDataSuccessS(state.data));
}

//----- Internal bloc
abstract class InternalDataBloc<Data> extends Bloc<DataE, DataS<Data>> {
  InternalDataBloc({
    EventTransformer<DataE>? transformer,
    OnLoading<Data>? overridedOnLoading,
    OnLoadingSuccess<Data>? overridedOnLoadingSuccess,
    OnLoadingError<Data>? overridedOnLoadingError,
    OnReloading<Data>? overridedOnReloading,
    OnReloadingFinished<Data>? overridedOnReloadingFinished,
    OnReloadingError<Data>? overridedOnReloadingError,
  })  : onLoading = overridedOnLoading ?? _$onLoading,
        onLoadingSuccess = overridedOnLoadingSuccess ?? _$onLoadingSuccess,
        onLoadingError = overridedOnLoadingError ?? _$onLoadingError,
        onReloading = overridedOnReloading ?? _$onReloading,
        onReloadingFinished =
            overridedOnReloadingFinished ?? _$onReloadingFinished,
        onReloadingError = overridedOnReloadingError ?? _$onReloadingError,
        super(const UnloadedDataS()) {
    on<DataE>(
      _handleEvent,
      transformer: transformer ?? droppable(),
    );
  }

  final OnLoading<Data> onLoading;
  final OnReloading<Data> onReloading;
  final OnLoadingSuccess<Data> onLoadingSuccess;
  final OnReloadingFinished<Data> onReloadingFinished;
  final OnLoadingError<Data> onLoadingError;
  final OnReloadingError<Data> onReloadingError;

  @protected
  FutureOr<Data> loadData(DataS<Data> oldState, LoadDataE event);

  FutureOr<void> _handleEvent(DataE event, Emitter<DataS<Data>> emit) {
    if (event is ReloadDataE) {
      return _reload(
        event,
        emit,
      );
    } else if (event is LoadDataE) {
      return _load(
        event,
        emit,
      );
    }
    if (event is UpdateDataE<Data>) {
      return _update(event, emit);
    }
    if (event is InitializeDataE<Data>) {
      return _initialize(event, emit);
    }
  }

  Future<void> _load(
    LoadDataE event,
    Emitter<DataS<Data>> emit,
  ) async {
    final oldState = state;
    if (oldState is! UnloadedDataS<Data>) {
      return;
    }
    try {
      onLoading(emit);
      final data = await loadData(oldState, event);

      onLoadingSuccess(emit, data);
    } on DataException catch (error) {
      onLoadingError(error, oldState, emit);
    } on Object catch (error, stackTrace) {
      onLoadingError(
        UnhandledDataException(error: error, stackTrace: stackTrace),
        oldState,
        emit,
      );

      rethrow;
    }
  }

  Future<void> _reload(
    ReloadDataE event,
    Emitter<DataS<Data>> emit,
  ) async {
    final oldState = state;
    if (oldState is! LoadedDataS<Data>) {
      return;
    }
    try {
      onReloading(emit, oldState, event);
      final data = await loadData(oldState, event);
      onReloadingFinished(emit, data);
      onLoadingSuccess(emit, data);
    } on DataException catch (error) {
      onReloadingError(error, oldState, emit);
    } on Object catch (error, stackTrace) {
      onReloadingError(
        UnhandledDataException(error: error, stackTrace: stackTrace),
        oldState,
        emit,
      );

      rethrow;
    }
  }

  FutureOr<void> _update(UpdateDataE<Data> event, Emitter<DataS<Data>> emit) {
    final oldState = state;
    if (oldState is LoadedDataS<Data>) {
      final updatedData = event.update(oldState.data);
      onLoadingSuccess(emit, updatedData);
    }
  }

  FutureOr<void> _initialize(
    InitializeDataE<Data> event,
    Emitter<DataS<Data>> emit,
  ) {
    if (state is UnloadedDataS<Data>) {
      emit(LoadedDataSuccessS(event.data));
    }
  }
}

//----- public bloc
abstract class DataBloc<Data> extends InternalDataBloc<Data> {
  DataBloc({
    EventTransformer<DataE>? transformer,
    OnLoadingError<Data>? overridedOnLoadingError,
    OnReloadingError<Data>? overridedOnReloadingError,
  }) : super(
          transformer: transformer,
          overridedOnLoadingError: overridedOnLoadingError,
          overridedOnReloadingError: overridedOnReloadingError,
        );
}
