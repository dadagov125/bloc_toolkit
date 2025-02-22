part of 'data_bloc.dart';

// ----- Loaded

@immutable
abstract class LoadedS<Data, Params> extends DataS<Data> {
  const LoadedS(
    this.data, {
    this.params,
    DataException? error,
  }) : super(error: error);

  @override
  // ignore: overridden_fields
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
  const LoadedDataS(Data data, {Params? params})
      : super(
          data,
          params: params,
        );
}

/// Loading
@immutable
class ReloadingDataS<Data, Params> extends LoadedS<Data, Params>
    implements LoadingS<Data> {
  ReloadingDataS(
    LoadedS<Data, Params> oldState, {
    required this.isNextLoading,
    Params? params,
  }) : super(
          oldState.data,
          params: params,
          error: oldState.error,
        );

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
    // ignore: avoid_implementing_value_types
    implements
        ErrorS<Data> {
  ReloadingDataErrorS(
    LoadedS<Data, Params> oldState,
    this.error, {
    Params? params,
  }) : super(oldState.data, params: params);

  @override
  // ignore: overridden_fields
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

///Submit
@immutable
class SubmittingDataS<Data, Params> extends LoadedS<Data, Params>
    implements LoadingS<Data> {
  SubmittingDataS(
    LoadedS<Data, Params> oldState, {
    Params? params,
  }) : super(oldState.data, params: params);
}

@immutable
class SubmittingDataErrorS<Data, Params> extends LoadedS<Data, Params>
    // ignore: avoid_implementing_value_types
    implements
        ErrorS<Data> {
  SubmittingDataErrorS(
    LoadedS<Data, Params> oldState,
    this.error, {
    Params? params,
  }) : super(oldState.data, params: params);

  @override
  // ignore: overridden_fields
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
