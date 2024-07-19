import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' show droppable;
import 'package:bloc_toolkit/src/excaption/data_exception.dart';
import 'package:bloc_toolkit/src/excaption/unhandled_data_exception.dart';
import 'package:meta/meta.dart' show immutable, protected;

part 'data_event.dart';

part 'data_state.dart';

part 'data_loaded_state.dart';

part 'data_unloaded_state.dart';

abstract class DataBloc<Data> extends Bloc<DataE, DataS<Data>> {
  DataBloc({
    EventTransformer<DataE>? transformer,
  }) : super(const UnloadedDataS()) {
    on<DataE>(
      handleEvent,
      transformer: transformer ?? droppable(),
    );
  }

  @protected
  FutureOr<void> handleEvent(DataE event, Emitter<DataS<Data>> emit) {
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

  @protected
  FutureOr<Data> loadData(DataS<Data> oldState, LoadDataE event);

  @protected
  void onReloadingError(
    DataException error,
    LoadedDataS<Data> state,
    Emitter<DataS<Data>> emit,
  ) {
    emit(ReloadingErrorS(state, error));
    emit(LoadedDataSuccessS(state.data));
  }

  @protected
  void onLoadingError(
    DataException error,
    UnloadedDataS<Data> state,
    Emitter<DataS<Data>> emit,
  ) {
    emit(LoadingDataErrorS(error));
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
      emit(const LoadingDataS());
      final data = await loadData(oldState, event);
      emit(LoadedDataSuccessS(data));
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
      emit(
        ReloadingDataS(
          oldState,
          isNextLoading: event.isNextLoading,
        ),
      );
      final data = await loadData(oldState, event);
      emit(ReloadingDataFinishedS(data));
      emit(LoadedDataSuccessS(data));
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
      emit(LoadedDataSuccessS(updatedData));
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
