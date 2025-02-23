part of 'data_bloc.dart';

// ----- Abstraction
@immutable
abstract class DataS<Data> {
  const DataS({
    this.data,
    this.error,
  });

  final Data? data;

  final DataException? error;
}

@immutable
abstract class IdleS<Data> extends DataS<Data> {
  const IdleS({
    Data? data,
    DataException? error,
  }) : super(data: data, error: error);
}

@immutable
abstract class LoadingS<Data> extends DataS<Data> {
  const LoadingS({
    Data? data,
    DataException? error,
  }) : super(data: data, error: error);
}

@immutable
abstract class ErrorS<Data> extends DataS<Data> {
  const ErrorS({
    required this.error,
    Data? data,
  }) : super(data: data, error: error);

  @override
  // ignore: overridden_fields
  final DataException error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorS &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
