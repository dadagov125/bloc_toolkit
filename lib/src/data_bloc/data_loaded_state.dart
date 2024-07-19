part of 'data_bloc.dart';

// ----- Loaded
@immutable
abstract class LoadedDataS<Data> extends DataS<Data> {
  const LoadedDataS(this.data);

  final Data data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadedDataS &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Idle
class LoadedDataSuccessS<Data> extends LoadedDataS<Data>
    implements ProgressFinished<Data> {
  const LoadedDataSuccessS(Data data) : super(data);
}

/// Progress
class ReloadingDataS<Data> extends LoadedDataS<Data> implements Progress<Data> {
  ReloadingDataS(
    LoadedDataS<Data> old, {
    required this.isNextLoading,
  }) : super(old.data);

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

/// Finished
class ReloadingDataFinishedS<Data> extends LoadedDataS<Data>
    implements ProgressFinished<Data> {
  const ReloadingDataFinishedS(Data data) : super(data);
}

/// Error&Finished
class ReloadingErrorS<Data> extends LoadedDataS<Data>
    implements ProgressError<Data> {
  ReloadingErrorS(
    LoadedDataS<Data> old,
    this.error,
  ) : super(old.data);

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
