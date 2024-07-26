part of 'data_bloc.dart';

// ----- Abstraction
@immutable
abstract class DataS<Data> {
  const DataS();
}

@immutable
abstract class IdleS<Data> extends DataS<Data> {
  const IdleS();
}

@immutable
abstract class LoadingS<Data> extends DataS<Data> {
  const LoadingS();
}

@immutable
abstract class ErrorS<Data> extends DataS<Data> {
  const ErrorS(this.error);

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
