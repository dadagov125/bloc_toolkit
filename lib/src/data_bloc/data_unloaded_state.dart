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
class LoadingDataErrorS<Data> extends UnloadedDataS<Data>
    implements ProgressError<Data> {
  const LoadingDataErrorS(this.error);

  @override
  final DataException error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingDataErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
