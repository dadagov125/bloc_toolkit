part of 'data_bloc.dart';

// ----- Unloaded

@immutable
abstract class UnloadedS<Data> extends DataS<Data> {
  const UnloadedS();
}

/// Idle
@immutable
class UnloadedDataS<Data> extends UnloadedS<Data> implements IdleS<Data> {
  const UnloadedDataS();
}

/// Loading
@immutable
class LoadingDataS<Data> extends UnloadedS<Data> implements LoadingS<Data> {
  const LoadingDataS();
}

/// Error
@immutable
class LoadingDataErrorS<Data, Params> extends UnloadedS<Data>
    implements ErrorS<Data> {
  const LoadingDataErrorS(this.error, {this.params});

  @override
  final DataException error;
  final Params? params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingDataErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
