part of 'data_bloc.dart';

// ----- Loaded
@immutable
abstract class LoadedDataS<Data, Params> extends DataS<Data> {
  const LoadedDataS(this.data, {this.params});

  final Data data;
  final Params? params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadedDataS &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          params == other.params;

  @override
  int get hashCode => data.hashCode ^ params.hashCode;
}

/// Idle
class LoadedDataSuccessS<Data, Params> extends LoadedDataS<Data, Params>
    implements ProgressFinished<Data> {
  const LoadedDataSuccessS(Data data, {Params? params})
      : super(data, params: params);
}

/// Progress
class ReloadingDataS<Data, Params> extends LoadedDataS<Data, Params>
    implements Progress<Data> {
  ReloadingDataS(LoadedDataS<Data, Params> oldState,
      {required this.isNextLoading})
      : super(oldState.data, params: oldState.params);

  final bool isNextLoading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ReloadingDataS &&
          runtimeType == other.runtimeType &&
          isNextLoading == other.isNextLoading;

  @override
  int get hashCode => super.hashCode ^ isNextLoading.hashCode;
}


/// Error&Finished
class ReloadingErrorS<Data, Params> extends LoadedDataS<Data, Params>
    implements ProgressError<Data> {
  ReloadingErrorS(
    LoadedDataS<Data, Params> oldState,
    this.error,
  ) : super(oldState.data, params: oldState.params);

  @override
  final DataException error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ReloadingErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => super.hashCode ^ error.hashCode;
}
