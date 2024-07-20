part of 'data_bloc.dart';

// ----- Unloaded

/// Idle
class UnloadedDataS<Data> extends DataS<Data> {
  const UnloadedDataS();
}

/// Progress
class LoadingDataS<Data> extends UnloadedDataS<Data> implements Progress<Data> {
  const LoadingDataS();
}

/// Error&Finished
@immutable
class LoadingDataErrorS<Data, Params> extends UnloadedDataS<Data>
    implements ProgressError<Data> {
  const LoadingDataErrorS(this.error, {this.params});

  @override
  final DataException error;
  final Params? params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingDataErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          params == other.params;

  @override
  int get hashCode => error.hashCode ^ params.hashCode;
}
