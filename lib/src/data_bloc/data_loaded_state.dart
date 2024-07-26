part of 'data_bloc.dart';

// ----- Loaded

@immutable
abstract class LoadedS<Data, Params> extends DataS<Data> {
  const LoadedS(this.data, {this.params});

  final Data data;
  final Params? params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadedS &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          params == other.params;

  @override
  int get hashCode => data.hashCode ^ params.hashCode;
}

/// Idle
@immutable
class LoadedDataS<Data, Params> extends LoadedS<Data, Params>
    implements IdleS<Data> {
  const LoadedDataS(Data data, {Params? params}) : super(data, params: params);
}

/// Loading
@immutable
class ReloadingDataS<Data, Params> extends LoadedS<Data, Params>
    implements LoadingS<Data> {
  ReloadingDataS(LoadedS<Data, Params> oldState, {required this.isNextLoading})
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

/// Error
@immutable
class ReloadingDataErrorS<Data, Params> extends LoadedS<Data, Params>
    implements ErrorS<Data> {
  ReloadingDataErrorS(
    LoadedS<Data, Params> oldState,
    this.error, {
    Params? params,
  }) : super(oldState.data, params: params);

  @override
  final DataException error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ReloadingDataErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => super.hashCode ^ error.hashCode;
}
